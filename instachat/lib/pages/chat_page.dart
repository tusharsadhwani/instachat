import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
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
  ChatService chatService;

  MessageBox _messageBox;
  ScrollController _controller;
  double _bottomInset;

  bool loadingMoreMessages = false;

  bool get isAtTop => _controller.offset < 100;

  bool get isAtBottom =>
      _controller.position.maxScrollExtent - _controller.offset < 20;

  void updateMessages() {
    setState(() {
      final msgs = chatService.messages;
      bool isInitialLoad = msgs.isEmpty;

      if (isInitialLoad || chatService.userSentNewMessage || isAtBottom) {
        _scrollToBottom();
      }
    });
  }

  Future<void> loadMoreMessages() async {
    loadingMoreMessages = true;
    await chatService.loadOlderMessages();
    loadingMoreMessages = false;
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
    _controller.addListener(() {
      if (isAtTop && !loadingMoreMessages && !chatService.allMessagesLoaded) {
        print('Loading more chats...');
        loadMoreMessages();
      }
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    auth = Provider.of<Auth>(context, listen: false);

    chatService = ChatService(auth, widget.chat.id);
    chatService.connectWebsocket();
    chatService.addListener(updateMessages);
    _messageBox = MessageBox(chatService);
  }

  @override
  void dispose() {
    _controller.dispose();
    chatService.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final newBottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    if (newBottomInset != _bottomInset) {
      _bottomInset = newBottomInset;
      if (isAtBottom) {
        _scrollToBottom();
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
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _controller,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (_, i) {
                      if (i == 0) if (chatService.allMessagesLoaded)
                        return Center(child: Text("All messages loaded"));
                      else
                        return Center(child: CircularProgressIndicator());

                      i -= 1;
                      final messages = chatService.messages;
                      final message = messages[i];
                      final isFirstMessageFromSender = i == 0 ||
                          messages[i - 1].senderId != message.senderId;

                      return message.senderId == auth.user.id
                          ? MessageRight(
                              message,
                              key: ValueKey(message.liked),
                              liked: message.liked,
                              onLikeChanged: (_) =>
                                  chatService.like(message.id),
                            )
                          : MessageLeft(
                              message,
                              key: ValueKey(message.liked),
                              liked: message.liked,
                              onLikeChanged: (_) =>
                                  chatService.like(message.id),
                              isFirstMessageFromSender:
                                  isFirstMessageFromSender,
                            );
                    },
                    itemCount: chatService.messages.length + 1,
                  ),
                ),
              ],
            ),
          ),
          _messageBox,
        ],
      ),
    );
  }
}
