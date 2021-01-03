import 'dart:convert';

import 'package:uuid/uuid.dart';

final uuid = Uuid();

class Message {
  final int id;
  final int senderId;
  final String senderName;
  final String content;

  Message({this.senderId, this.senderName, this.content})
      : this.id = uuid.v4().hashCode;

  Message.fromMap(Map<String, dynamic> message)
      : senderId = message['userid'],
        senderName = 'Test',
        content = message['text'],
        id = message['id'];

  String toJson() {
    return jsonEncode({
      'id': id,
      'userid': senderId,
      'text': content,
    });
  }
}
