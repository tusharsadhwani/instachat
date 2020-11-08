import '../server.dart';
import 'chat.dart';

class Message extends ManagedObject<_Message> implements _Message {}

class _Message {
  @primaryKey
  int id;

  @Relate(#messages)
  Chat chat;

  @Column()
  String text;
}
