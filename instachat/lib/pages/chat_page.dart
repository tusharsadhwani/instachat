import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suspense/suspense.dart';

import '../models/auth_user.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../widgets/insta_app_bar.dart';
import '../widgets/message.dart';
import '../widgets/message_box.dart';

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
    return Scaffold(
      appBar: InstaAppBar(
        title: widget.chat.name,
        leading: CircleAvatar(
          backgroundImage: NetworkImage(widget.chat.imageUrl),
          radius: 18,
        ),
      ),
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
