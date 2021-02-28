import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/new_chat_page.dart';
import '../services/chats_service.dart';
import '../widgets/chat_tile.dart';
import '../widgets/insta_app_bar.dart';
import '../widgets/search_bar.dart';

class ChatsPage extends StatefulWidget {
  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late final ChatsService chatsService = Provider.of<ChatsService>(context);

  void newChat() async {
    final refresh =
        await Navigator.of(context).pushNamed<bool>(NewChatPage.routeName) ??
            false;
    if (refresh) chatsService.updateChats();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: InstaAppBar(
          title: 'InstaChat',
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: newChat,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: chatsService.updateChats,
          child: Column(
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
                  itemCount: chatsService.chats.length,
                  itemBuilder: (_, i) => ChatTile(chat: chatsService.chats[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
