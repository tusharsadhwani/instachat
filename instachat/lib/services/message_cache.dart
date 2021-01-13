import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/message.dart';

class MessageCache {
  Queue<Message> messages;

  MessageCache() {
    messages = Queue();
  }

  MessageCache.fromMap(dynamic data) {
    messages = Queue.from(data.map<Message>((m) => Message.fromMap(m)));
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

  bool get full => messages.length >= 15;

  void pushFirst(Message message) {
    if (messages.length < 15) messages.addFirst(message);
  }

  void pushLast(Message message) {
    messages.addLast(message);
    if (messages.length > 15) messages.removeFirst();
  }

  Future<void> save({@required String filename}) async {
    print('saving last 15 to cache...');
    final cacheMessages = messages.map((m) => m.toMap()).toList();
    print('cache order:');
    print(cacheMessages.map((m) => m['id']).join(' '));

    final docDir = await getApplicationDocumentsDirectory();
    print(docDir.path);

    final cacheFile = File(path.join(docDir.path, filename));

    cacheFile.writeAsStringSync(jsonEncode(cacheMessages));
  }
}
