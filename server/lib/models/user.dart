import '../server.dart';
import 'chat.dart';

class User extends ManagedObject<_User> implements _User {}

class _User {
  @primaryKey
  int id;

  @Column(unique: true)
  String username;

  @Column()
  String name;

  ManagedSet<UserChat> userChats;
}

class UserChat extends ManagedObject<_UserChat> implements _UserChat {}

class _UserChat {
  @primaryKey
  int id;

  @Relate(#userChats)
  Chat chat;

  @Relate(#userChats)
  User user;
}
