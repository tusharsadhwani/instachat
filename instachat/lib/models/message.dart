import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class Message {
  final String id;
  final int index;
  final int senderId;
  final String senderName;
  final String content;

  bool liked;

  Message({
    @required this.senderId,
    @required this.senderName,
    @required this.content,
    this.index = 0,
    this.liked = false,
  }) : this.id = uuid.v4();

  Message.fromMap(Map<String, dynamic> message)
      : senderId = message['userid'],
        senderName = 'Test',
        content = message['text'],
        liked = message['liked'],
        id = message['uuid'],
        index = message['id'];

  Map<String, dynamic> toMap() {
    return {
      'id': index,
      'uuid': id,
      'userid': senderId,
      'text': content,
      'liked': liked,
    };
  }
}
