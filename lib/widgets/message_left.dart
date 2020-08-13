import 'package:flutter/material.dart';

import '../models/message.dart';
import '../widgets/likeable.dart';

class MessageLeft extends StatelessWidget {
  final Message message;

  const MessageLeft({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://i.pravatar.cc/50?img=2'),
          ),
          SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.all(3),
            child: Likeable(
              key: ValueKey(message.id),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).appBarTheme.color,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    message.content,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
