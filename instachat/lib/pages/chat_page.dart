import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat.dart';
import '../models/message.dart';
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

  bool get isAtTop =>
      _controller.offset - _controller.position.minScrollExtent < 100;

  bool get isAtBottom =>
      _controller.position.maxScrollExtent - _controller.offset < 100;

  void _updateMessages() {
    setState(() {
      if (chatService.latestMessagesLoaded)
        _scrollToBottom();
      else if (chatService.userSentNewMessage) _jumpToLatestMessages();
    });
  }

  void _scrollListener() {
    if (isAtTop &&
        !chatService.loadingOlderMessages &&
        !chatService.allOlderMessagesLoaded) {
      print('Loading more older chats...');
      chatService.loadOlderMessages();
    }
    if (isAtBottom &&
        !chatService.loadingNewerMessages &&
        !chatService.allNewerMessagesLoaded) {
      print('Loading more newer chats...');
      chatService.loadNewerMessages();
    }
  }

  void _scrollToBottom() {
    print('scrolling to bottom');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOutQuad,
      );
    });
  }

  void _jumpToLatestMessages() async {
    await chatService.jumpToLatestMessages();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    });

    _controller.addListener(_scrollListener);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    auth = Provider.of<Auth>(context, listen: false);

    chatService = ChatService(auth, widget.chat.id);
    _messageBox = MessageBox(chatService);

    await chatService.connectWebsocket();
    chatService.addListener(_updateMessages);
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
      if (isAtBottom) _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Key centerKey = ValueKey('new-messages');

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
            child: CustomScrollView(
              controller: _controller,
              cacheExtent: double.maxFinite,
              center: centerKey,
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      if (i == chatService.oldMessages.length) {
                        if (chatService.allOlderMessagesLoaded)
                          return Center(child: Text("All messages loaded"));
                        else
                          return Center(child: CircularProgressIndicator());
                      }

                      final messages = chatService.oldMessages;
                      final isFirstMessage = i == messages.length - 1 ||
                          messages[i].senderId != messages[i + 1].senderId;

                      return renderMessage(messages, i, isFirstMessage);
                    },
                    childCount: chatService.oldMessages.length + 1,
                  ),
                ),
                SliverList(
                  key: centerKey,
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      if (i == chatService.messages.length) {
                        if (chatService.allNewerMessagesLoaded)
                          return Center(child: Text("All messages loaded"));
                        else
                          return Center(child: CircularProgressIndicator());
                      }

                      final messages = chatService.messages;
                      final isFirstMessage = i == 0 ||
                          messages[i].senderId != messages[i - 1].senderId;

                      return renderMessage(messages, i, isFirstMessage);
                    },
                    childCount: chatService.messages.length + 1,
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

  Widget renderMessage(List<Message> messages, int index, bool isFirstMessage) {
    final message = messages[index];

    return message.senderId == auth.user.id
        ? MessageRight(
            message,
            key: ValueKey(message.liked),
            liked: message.liked,
            onLikeChanged: (_) => chatService.like(message.id),
          )
        : MessageLeft(
            message,
            key: ValueKey(message.liked),
            liked: message.liked,
            onLikeChanged: (_) => chatService.like(message.id),
            isFirstMessageFromSender: isFirstMessage,
          );
  }
}
