import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instachat/pages/new_chat_page.dart';
import 'package:provider/provider.dart';

import '../models/auth_user.dart';
import '../models/chat.dart';
import '../widgets/insta_app_bar.dart';
import '../widgets/search_bar.dart';
import '../widgets/chat_tile.dart';

class ChatsPage extends StatefulWidget {
  static const routeName = '/chats';

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  AuthUser _authUser;
  List<Chat> chats = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authUser = Provider.of<AuthUser>(context, listen: false);
    refreshChats();
  }

  Future<void> refreshChats() async {
    final userChats = await Firestore.instance
        .collection('user')
        .document(_authUser.account.id)
        .collection('chat')
        .getDocuments();

    final chatIds = userChats.documents.map((doc) => doc.data['id']).toList();

    // TODO: this could break for more than 10 chatIds
    if (chatIds.length > 0) {
      final chatDocs = await Firestore.instance
          .collection('chat')
          .where('id', whereIn: chatIds)
          .getDocuments();

      setState(() {
        chats = chatDocs.documents.map((d) => Chat.fromMap(d.data)).toList();
      });
    }
  }

  void newChat() async {
    final refresh =
        await Navigator.of(context).pushNamed(NewChatPage.routeName) ?? false;
    if (refresh) refreshChats();
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
          onRefresh: refreshChats,
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
                  itemCount: chats.length,
                  itemBuilder: (_, i) => ChatTile(chat: chats[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
