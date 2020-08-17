import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suspense/suspense.dart';

import '../models/auth_user.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../widgets/insta_app_bar.dart';
import '../widgets/message.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;

  ChatPage(this.chat);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  AuthUser authUser;
  String chatId;

  MessageBox _messageBox;
  ScrollController _scrollController;
  int messageCount;

  void addMessage(String newMessage) {
    Firestore.instance
        .collection('chat')
        .document(chatId)
        .collection('message')
        .add({
      'sender': authUser.account.id,
      'name': authUser.account.displayName,
      'content': newMessage,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  void initState() {
    super.initState();
    _messageBox = MessageBox(addMessage);
    _scrollController = ScrollController();
    messageCount = 0;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    authUser = Provider.of<AuthUser>(context, listen: false);
    final docs = await Firestore.instance
        .collection('chat')
        .where('id', isEqualTo: widget.chat.id)
        .limit(1)
        .getDocuments();
    docs.documents.forEach((docs) {
      setState(() {
        chatId = docs.documentID;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InstaAppBar(title: widget.chat.name),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: Suspense<QuerySnapshot>.stream(
          stream: Firestore.instance
              .collection('chat')
              .document(chatId)
              .collection('message')
              .orderBy('timestamp')
              .snapshots(),
          fallback: Center(child: CircularProgressIndicator()),
          builder: (snapshot) {
            List<Message> messages = snapshot.documents
                .map((doc) => Message.fromMap(doc.data))
                .toList();
            if (messages.length != messageCount) {
              messageCount = messages.length;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeOutQuad,
                );
              });
            }

            String prevSenderId;
            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemBuilder: (_, i) {
                final message = messages[i];
                final senderId = message.senderId;

                bool isFirstMessageFromSender = false;
                if (senderId != null && senderId != prevSenderId)
                  isFirstMessageFromSender = true;

                prevSenderId = senderId;

                return message.senderId == authUser.account.id
                    ? MessageRight(message: message)
                    : MessageLeft(
                        message: message,
                        isFirstMessageFromSender: isFirstMessageFromSender,
                      );
              },
              itemCount: messages.length,
            );
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
