import 'dart:io';

import 'package:flutter/material.dart';
import 'package:instachat/services/chat_service.dart';
import 'package:provider/provider.dart';

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
  Auth auth;
  MessageService chatService;
  String chatId;

  MessageBox _messageBox;
  ScrollController _controller;
  double _bottomInset;

  List<Message> messageCache = [];

  WebSocket ws;

  void updateMessages() {
    setState(() {
      messageCache = chatService.messages;
    });
  }

  void addMessage(String newMessage) {
    ws.add(newMessage);
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
    auth = Provider.of<Auth>(context, listen: false);

    chatService = MessageService(auth, widget.chat.id);
    chatService.connectWebsocket();
    chatService.addListener(updateMessages);
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
            child: ListView.builder(
              controller: _controller,
              padding: const EdgeInsets.all(12),
              itemBuilder: (_, i) {
                final message = messageCache[i];

                return message.senderId == auth.user.id
                    ? MessageRight(message: message)
                    : MessageLeft(
                        message: message,
                        isFirstMessageFromSender: false,
                      );
              },
              itemCount: messageCache.length,
            ),
          ),
          _messageBox,
        ],
      ),
    );
  }
}
