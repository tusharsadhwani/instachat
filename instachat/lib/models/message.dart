import 'package:uuid/uuid.dart';

final uuid = Uuid();

class Message {
  final int id;
  final int senderId;
  final String senderName;
  final String content;
  // final DateTime timestamp;

  Message.fromMap(Map<String, dynamic> message)
      : senderId = message['userid'],
        senderName = 'Test',
        content = message['text'],
        // timestamp = DateTime.fromMillisecondsSinceEpoch(message['timestamp']),
        id = message['id'];
}
