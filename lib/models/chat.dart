import 'package:meta/meta.dart';

class Chat {
  final String id;
  final String name;
  final String imageUrl;

  const Chat({
    @required this.id,
    @required this.name,
    @required this.imageUrl,
  });

  Chat.fromMap(Map<String, dynamic> chat)
      : id = chat['id'],
        name = chat['name'],
        imageUrl = chat['imageUrl'];
}

class Room extends Chat {
  Room.fromMap(Map<String, dynamic> room) : super.fromMap(room);
}
