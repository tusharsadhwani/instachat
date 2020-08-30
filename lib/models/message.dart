import 'package:uuid/uuid.dart';

final uuid = Uuid();

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;

  Message.fromMap(String id, Map<String, dynamic> message)
      : senderId = message['sender'],
        senderName = message['name'],
        content = message['content'],
        timestamp = DateTime.fromMillisecondsSinceEpoch(message['timestamp']),
        id = id;
}
