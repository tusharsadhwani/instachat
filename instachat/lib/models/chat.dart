class Chat {
  final int id;
  final String name;
  final String address;
  final String imageUrl;

  Chat.fromMap(Map<String, dynamic> chat)
      : id = chat['id'],
        name = chat['name'],
        address = chat['address'],
        imageUrl = chat['imageUrl'] ?? "https://picsum.photos/80/80";
}
