import 'package:aqueduct/managed_auth.dart';

import '../server.dart';
import 'chat.dart';

class User extends ManagedObject<_User>
    implements _User, ManagedAuthResourceOwner<_User> {
  @Serialize(input: true, output: false)
  String password;
}

class _User extends ResourceOwnerTableDefinition {
  @Column()
  String name;

  ManagedSet<UserChat> createdChats;

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
