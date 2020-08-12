import 'package:flutter/material.dart';

import '../models/message.dart';

class MessageRight extends StatelessWidget {
  final Message message;

  const MessageRight(this.message);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).appBarTheme.color,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(message.content),
          ),
        ),
      ),
    );
  }
}
