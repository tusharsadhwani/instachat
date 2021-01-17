import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class Message {
  final String id;
  final int index;
  final int senderId;
  final String senderName;
  final String content;
  final String imageUrl;

  bool liked;

  Message({
    @required this.senderId,
    @required this.senderName,
    this.content,
    this.imageUrl,
    this.index = 0,
    this.liked = false,
  })  : this.id = uuid.v4(),
        assert(
          (content != null && content.trim() != "") ||
              (imageUrl != null && imageUrl.trim() != ""),
          "Either content or image url must be provided",
        );

  Message.fromMap(Map<String, dynamic> message)
      : senderId = message['userid'],
        senderName = 'Test',
        content = message['text'],
        liked = message['liked'],
        id = message['uuid'],
        index = message['id'],
        imageUrl = message['imageUrl'];

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
