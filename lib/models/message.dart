import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String content;

  Message({
    @required this.senderId,
    @required this.senderName,
    @required this.content,
  }) : id = uuid.v4();
}
