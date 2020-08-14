import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instachat/models/auth_user.dart';
import 'package:provider/provider.dart';

import '../models/message.dart';
import '../widgets/insta_app_bar.dart';
import '../widgets/message_left.dart';
import '../widgets/message_right.dart';

class ChatPage extends StatefulWidget {
  final String chatId;

  ChatPage(this.chatId);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  AuthUser authUser;
  String chatDocId = '?'; //TODO: rename RoomId to room username or sth

  MessageBox _messageBox;
  ScrollController _scrollController;
  bool _needsScrollToBottom = false;

  void addMessage(String newMessage) {}

  @override
  void initState() {
    _messageBox = MessageBox(addMessage);
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    authUser = Provider.of<AuthUser>(context);
    final docs = await Firestore.instance
        .collection('chat')
        .where('id', isEqualTo: widget.chatId)
        .limit(1)
        .getDocuments();
    docs.documents.forEach((docs) {
      chatDocId = docs.documentID;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsScrollToBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOutQuad,
        );
      });
    }
    return Scaffold(
      appBar: InstaAppBar(title: 'Test Log'),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('chat')
              .document(chatDocId)
              .collection('message')
              .snapshots(),
          builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot,
          ) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                print('messages: ${snapshot.data.documents.length}');
                List<Message> messages = snapshot.data.documents
                    .map((e) => Message.fromMap(e.data))
                    .toList();
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (_, i) {
                    final message = messages[i];
                    return message.senderId == authUser.account.id
                        ? MessageLeft(message: message)
                        : MessageRight(message: message);
                  },
                  itemCount: messages.length,
                );
            }
          },
        ),
      ),
      bottomSheet: _messageBox,
    );
  }
}

class MessageBox extends StatefulWidget {
  final void Function(String) addMessage;

  MessageBox(this.addMessage);

  @override
  _MessageBoxState createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  var _messageController = TextEditingController();

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText != '') {
      widget.addMessage(messageText);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.all(14),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).accentColor,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    minLines: 1,
                    maxLines: 5,
                    controller: _messageController,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _sendMessage,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Send',
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(color: Colors.blue),
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
