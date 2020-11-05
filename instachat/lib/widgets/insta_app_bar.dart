import 'package:flutter/material.dart';

class InstaAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;

  InstaAppBar({
    Key key,
    @required this.title,
    this.leading,
    this.actions,
  })  : preferredSize = Size.fromHeight(50.0),
        super(key: key);

  final Widget leading;
  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          if (leading != null) ...[
            leading,
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
