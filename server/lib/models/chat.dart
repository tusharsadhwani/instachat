import '../server.dart';

class Chat extends ManagedObject<_Chat> implements _Chat {}

class _Chat {
  @primaryKey
  int id;

  @Column(unique: true)
  String username;

  @Column()
  String name;
}
