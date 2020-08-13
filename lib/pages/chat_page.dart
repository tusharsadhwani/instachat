import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/message.dart';
import '../widgets/insta_app_bar.dart';
import '../widgets/message_left.dart';
import '../widgets/message_right.dart';

class ChatPage extends StatefulWidget {
  static const routeName = '/chat';

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final messages = <Message>[
    Message(senderId: 'sender', senderName: 'Test', content: 'Yoi'),
    Message(senderId: 'receiver', senderName: 'Test', content: 'Yoi'),
    Message(
      senderId: 'sender',
      senderName: 'Test',
      content: 'Looks like insta\nright?',
    ),
  ];
  MessageBox _messageBox;
  ScrollController _scrollController;

  void addMessage(String newMessage) {
    setState(() {
      messages.add(Message(
        senderId: 'receiver',
        senderName: 'Test',
        content: newMessage,
      ));

      Future.delayed(
        // TODO: why do we need to delay this?
        Duration(milliseconds: 50),
        () => _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOutQuad,
        ),
      );
    });
  }

  @override
  void initState() {
    _messageBox = MessageBox(addMessage);
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).appBarTheme.color,
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: InstaAppBar(
            title: 'Test Log',
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemBuilder: (_, i) {
                final message = messages[i];
                return message.senderId == 'sender'
                    ? MessageLeft(message: message)
                    : MessageRight(message: message);
              },
              itemCount: messages.length,
            ),
          ),
          bottomSheet: _messageBox,
        ),
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
    widget.addMessage(_messageController.text);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.all(12),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).accentColor,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
                        vertical: 2,
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
