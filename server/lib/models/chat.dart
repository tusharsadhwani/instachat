import '../server.dart';
import 'message.dart';
import 'user.dart';

class Chat extends ManagedObject<_Chat> implements _Chat {}

class _Chat {
  @primaryKey
  int id;

  @Column(unique: true)
  String address;

  @Relate(#createdChats)
  User owner;

  @Column()
  String name;

  ManagedSet<Message> messages;

  ManagedSet<UserChat> userChats;
}
