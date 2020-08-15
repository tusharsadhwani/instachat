import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;

  Message({
    @required this.senderId,
    @required this.senderName,
    @required this.content,
    @required this.timestamp,
  }) : id = uuid.v4();

  Message.fromMap(Map<String, dynamic> message)
      : senderId = message['sender'],
        senderName = message['name'],
        content = message['content'],
        timestamp = DateTime.fromMillisecondsSinceEpoch(message['timestamp']),
        id = uuid.v4();
}
