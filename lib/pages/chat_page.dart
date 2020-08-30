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

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  AuthUser authUser;
  String chatId;

  MessageBox _messageBox;
  ScrollController _controller;
  double _bottomInset;

  Stream<QuerySnapshot> _msgStream = Stream.empty();
  List<Message> messageCache = [];

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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOutQuad,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = ScrollController();
    _messageBox = MessageBox(addMessage);
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
    String newChatId;
    docs.documents.forEach((docs) {
      newChatId = docs.documentID.toString();
      setState(() {
        chatId = newChatId;
        _msgStream = Firestore.instance
            .collection('chat')
            .document(chatId)
            .collection('message')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .snapshots();
      });
    });

    final lastFewChats = await Firestore.instance
        .collection('chat')
        .document(newChatId)
        .collection('message')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .getDocuments();

    setState(() {
      messageCache.addAll(lastFewChats.documents
          .map((msg) => Message.fromMap(msg.documentID, msg.data))
          .toList()
          .reversed);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final newBottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    if (newBottomInset != _bottomInset) {
      if (_controller.position.maxScrollExtent - _controller.offset < 10) {
        _scrollToBottom();
        _bottomInset = newBottomInset;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return Scaffold(
      appBar: InstaAppBar(title: widget.chat.name),
      body: Column(
        children: [
          Expanded(
            child: Suspense<QuerySnapshot>.stream(
              stream: _msgStream,
              fallback: Center(child: CircularProgressIndicator()),
              builder: (snapshot) {
                if (snapshot.documentChanges.length > 0) {
                  final lastDoc = snapshot.documentChanges.last.document;
                  Message newMessage =
                      Message.fromMap(lastDoc.documentID, lastDoc.data);
                  if (messageCache.isNotEmpty &&
                      messageCache.last.id != newMessage.id) {
                    messageCache.add(newMessage);
                  }
                  _scrollToBottom();
                }

                String prevSenderId;
                return ListView.builder(
                  controller: _controller,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (_, i) {
                    final message = messageCache[i];
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
                  itemCount: messageCache.length,
                );
              },
            ),
          ),
          _messageBox,
        ],
      ),
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
