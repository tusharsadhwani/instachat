import 'package:flutter/material.dart';

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
