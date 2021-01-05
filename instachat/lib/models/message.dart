import 'package:uuid/uuid.dart';

final uuid = Uuid();

class Message {
  final String id;
  final int senderId;
  final String senderName;
  final String content;

  bool liked;

  Message({
    this.senderId,
    this.senderName,
    this.content,
    this.liked,
  }) : this.id = uuid.v4();

  Message.fromMap(Map<String, dynamic> message)
      : senderId = message['userid'],
        senderName = 'Test',
        content = message['text'],
        liked = message['liked'] ?? false,
        id = message['uuid'];

  Map<String, dynamic> toMap() {
    return {
      'uuid': id,
      'userid': senderId,
      'text': content,
      'liked': liked,
    };
  }
}
