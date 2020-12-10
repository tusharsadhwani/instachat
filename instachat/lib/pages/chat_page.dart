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
  AuthUser authUser;
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

    initWebsocket();
  }

  void initWebsocket() async {
    try {
      ws = await WebSocket.connect('ws://10.0.2.2:3000/ws/123');
      if (ws?.readyState == WebSocket.open) {
        ws.add('client connected');
        ws.listen(
          (data) {
            print('recv: $data');
          },
          onDone: () => print('[+]Done :)'),
          onError: (err) => print('[!]Error -- ${err.toString()}'),
          cancelOnError: true,
        );
      } else
        print('[!]Connection Denied');
    } catch (e) {
      print('err: $e');
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    authUser = Provider.of<AuthUser>(context, listen: false);

    chatService = MessageService(authUser, widget.chat.id);
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

                return message.senderId == authUser.user.id
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
