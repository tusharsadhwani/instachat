import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/chat.dart';
import '../widgets/insta_app_bar.dart';
import '../widgets/search_bar.dart';

import 'chat_page.dart';

class ChatsPage extends StatefulWidget {
  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final chats = <Chat>[
    Chat(id: '1', name: 'Test Log', imageUrl: 'https://i.pravatar.cc/80?img=2'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.black,
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: InstaAppBar(title: 'InstaChat'),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchBar(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Messages',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (_, __) => SizedBox(height: 8),
                  itemCount: chats.length,
                  itemBuilder: (_, i) => InkWell(
                    onTap: () =>
                        Navigator.of(context).pushNamed(ChatPage.routeName),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(chats[i].imageUrl),
                      ),
                      title: Text(chats[i].name),
                      subtitle: Text(
                        'Liked a message',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
