class Chat {
  final int id;
  final String name;
  final String imageUrl;

  Chat.fromMap(Map<String, dynamic> chat)
      : id = chat['id'],
        name = chat['name'],
        imageUrl = chat['imageUrl'] ?? "https://picsum.photos/80/80";
}

class Room extends Chat {
  Room.fromMap(Map<String, dynamic> room) : super.fromMap(room);
}
