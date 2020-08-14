import 'package:flutter/material.dart';

class InstaAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;

  InstaAppBar({
    Key key,
    @required this.title,
    this.actions,
  })  : preferredSize = Size.fromHeight(50.0),
        super(key: key);

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headline6,
      ),
      actions: actions,
    );
  }
}
