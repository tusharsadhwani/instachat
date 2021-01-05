import 'package:flutter/material.dart';

import './likeable.dart';
import '../models/message.dart';

class MessageBase extends StatelessWidget {
  const MessageBase(
    this.message, {
    @required this.liked,
    this.onLikeChanged,
    Key key,
    this.backgroundColor = Colors.transparent,
  }) : super(key: key);

  final Message message;
  final bool liked;
  final void Function(bool newValue) onLikeChanged;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Likeable(
      initiallyLiked: liked,
      onLikeChanged: onLikeChanged,
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
  final bool liked;
  final void Function(bool newValue) onLikeChanged;
  final bool isFirstMessageFromSender;

  const MessageLeft(
    this.message, {
    @required this.liked,
    Key key,
    this.onLikeChanged,
    this.isFirstMessageFromSender = false,
  }) : super(key: key);

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isFirstMessageFromSender)
                    Padding(
                      padding: const EdgeInsets.only(left: 15, bottom: 5),
                      child: Text(
                        message.senderName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  MessageBase(
                    message,
                    liked: liked,
                    onLikeChanged: onLikeChanged,
                  ),
                ],
              ),
            ),
            SizedBox(width: 50),
          ],
        ),
      ),
    );
  }
}

class MessageRight extends StatelessWidget {
  final Message message;
  final bool liked;
  final void Function(bool newValue) onLikeChanged;

  const MessageRight(
    this.message, {
    @required this.liked,
    Key key,
    this.onLikeChanged,
  }) : super(key: key);

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
                  message,
                  liked: liked,
                  onLikeChanged: onLikeChanged,
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
