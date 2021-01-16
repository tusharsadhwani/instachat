import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/message.dart';

class MessageCache {
  Queue<Message> messages;
  String filename;

  MessageCache({@required this.filename}) {
    messages = Queue();
  }

  MessageCache.fromMap(dynamic data, {@required this.filename}) {
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

  int get prev {
    return top == 1 ? -1 : top - 1;
  }

  int get next {
    if (messages.isEmpty) return -1;
    return bottom + 1;
  }

  bool get full => messages.length >= 15;

  void pushFirst(Message message) {
    if (messages.length < 15) messages.addFirst(message);
  }

  void pushLast(Message message) {
    messages.addLast(message);
    if (messages.length > 15) messages.removeFirst();
  }

  Future<void> save() async {
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
