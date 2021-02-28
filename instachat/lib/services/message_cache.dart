import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/message.dart';

class MessageCache {
  static const limit = 15;

  late final Queue<Message> _messages;
  Queue<Message> get messages => _messages;

  String filename;

  MessageCache({required this.filename}) {
    _messages = Queue();
  }

  MessageCache.fromMap(dynamic data, {required this.filename}) {
    _messages = Queue.from(data.map<Message>((m) => Message.fromMap(m)));
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
    return top == 1 ? -1 : top - 1;
  }

  int get next {
    if (messages.isEmpty) return -1;
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
    final docDir = await getApplicationDocumentsDirectory();
    if (docDir == null)
      throw Exception('Cannot save, documents directory not found');

    final cacheFile = File(path.join(docDir.path, filename));

    final cacheMessageData = messages.map((m) => m.toMap()).toList();
    cacheFile.writeAsStringSync(jsonEncode(cacheMessageData));
  }
}
