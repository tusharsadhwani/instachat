import 'package:flutter/material.dart';

class InstaAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize = Size.fromHeight(50.0);

  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  InstaAppBar({Key? key, required this.title, this.leading, this.actions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: 10),
          ],
          Text(
            title,
            style: Theme.of(context).textTheme.headline6,
          ),
        ],
      ),
      actions: actions,
    );
  }
}
