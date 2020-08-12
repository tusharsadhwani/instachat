import 'package:meta/meta.dart';

class Message {
  final String senderId;
  final String senderName;
  final String content;

  Message({
    @required this.senderId,
    @required this.senderName,
    @required this.content,
  });
}
