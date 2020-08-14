import 'package:flutter/material.dart';
import 'package:instachat/models/chat.dart';

import '../pages/chat_page.dart';

class ChatTile extends StatelessWidget {
  final Chat chat;

  const ChatTile({Key key, this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatPage(chat.id),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(chat.imageUrl),
        ),
        title: Text(
          chat.name,
          style: TextStyle(fontSize: 14),
        ),
        subtitle: Text(
          'Liked a message',
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
