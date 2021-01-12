import 'dart:collection';
import 'dart:convert';

import '../models/message.dart';

class MessageCache {
  Queue<Message> messages;

  MessageCache() {
    messages = Queue();
  }

  MessageCache.fromMap(dynamic data) {
    messages = data.map<Message>((m) => Message.fromMap(m)).toList();
  }

  String toJson() {
    return jsonEncode(messages);
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

  void pushFirst(Message message) {
    messages.addFirst(message);
  }

  void pushLast(Message message) {
    messages.addLast(message);
  }
}
