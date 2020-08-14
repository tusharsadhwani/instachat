import 'package:flutter/material.dart';

import '../models/message.dart';
import '../widgets/likeable.dart';

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
              backgroundImage: NetworkImage('https://i.pravatar.cc/80?img=2'),
            ),
            SizedBox(width: 12),
            Likeable(
              key: ValueKey(message.id),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).appBarTheme.color,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(message.content),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
