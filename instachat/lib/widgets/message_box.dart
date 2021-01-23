import 'package:flutter/material.dart';

import '../models/message.dart';
import '../services/chat_service.dart';

class MessageBox extends StatefulWidget {
  final ChatService chatService;

  MessageBox(this.chatService);

  @override
  _MessageBoxState createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  TextEditingController _messageController;
  bool textIsEmpty;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    textIsEmpty = true;

    _messageController.addListener(() {
      final messageText = _messageController.text.trim();
      setState(() => textIsEmpty = messageText == '');
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText == '') return;

    final message = Message(
      senderId: widget.chatService.auth.user.id,
      senderName: widget.chatService.auth.user.name,
      content: messageText,
    );
    widget.chatService.sendMessage(message);
    _messageController.clear();
  }

  Future<void> sendImage() async {
    final pickedImage = await widget.chatService.pickImage();

    setState(() {
      if (pickedImage != null) {
        widget.chatService.sendImage(pickedImage.path);
      } else {
        print('No image selected.');
      }
    });
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
              if (textIsEmpty)
                IconButton(
                  icon: Icon(Icons.attach_file),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  color: Colors.grey,
                  onPressed: sendImage,
                ),
              GestureDetector(
                onTap: sendMessage,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 16),
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
