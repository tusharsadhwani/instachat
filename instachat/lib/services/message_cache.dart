import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/message.dart';

class MessageCache {
  static const limit = 15;

  Queue<Message> _messages;
  Queue<Message> get messages => _messages;

  String filename;

  MessageCache({@required this.filename});

  Future<void> initialize() async {
    if (kIsWeb) {
      _messages = Queue();
      return;
    }

    final docDir = await getApplicationDocumentsDirectory();
    final cacheFile = File(path.join(docDir.path, this.filename));

    if (!cacheFile.existsSync()) {
      _messages = Queue();
      return;
    }

    final cacheJson = cacheFile.readAsStringSync();
    final cacheData = jsonDecode(cacheJson);
    _messages = Queue.from(cacheData.map<Message>((m) => Message.fromMap(m)));
  }

  bool get isEmpty => messages.isEmpty;

  int get top {
    if (messages.isEmpty) return -1;
    return messages.first.index;
  }

  int get bottom {
    if (messages.isEmpty) return -1;
    return messages.last.index;
  }

  int get prev {
    if (messages.isEmpty) return -1;
    return top - 1;
  }

  int get next {
    return bottom + 1;
  }

  bool get full => messages.length >= 15;

  void pushFirst(Message message) {
    if (messages.length < limit) messages.addFirst(message);
  }

  void pushLast(Message message) {
    messages.addLast(message);
    if (messages.length > limit) messages.removeFirst();
  }

  void clear() {
    _messages = Queue();
  }

  Future<void> save() async {
    if (kIsWeb) return;

    final docDir = await getApplicationDocumentsDirectory();
    final cacheFile = File(path.join(docDir.path, filename));

    final cacheMessageData = messages.map((m) => m.toMap()).toList();
    cacheFile.writeAsStringSync(jsonEncode(cacheMessageData));
  }
}
