import 'package:flutter/material.dart';

import '../models/message.dart';
import 'likeable.dart';

class MessageBase extends StatelessWidget {
  const MessageBase({
    Key key,
    @required this.message,
    this.backgroundColor = Colors.transparent,
  }) : super(key: key);

  final Message message;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Likeable(
      key: ValueKey(message.id),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).appBarTheme.color,
          ),
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(message.content),
        ),
      ),
    );
  }
}

class MessageLeft extends StatelessWidget {
  final Message message;

  const MessageLeft({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(width: 4),
            CircleAvatar(
              radius: 17,
              backgroundImage: NetworkImage('https://picsum.photos/id/327/120'),
            ),
            SizedBox(width: 12),
            Expanded(child: MessageBase(message: message)),
            SizedBox(width: 50),
          ],
        ),
      ),
    );
  }
}

class MessageRight extends StatelessWidget {
  final Message message;

  const MessageRight({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            SizedBox(width: 50),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: MessageBase(
                  message: message,
                  backgroundColor: Theme.of(context).appBarTheme.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
