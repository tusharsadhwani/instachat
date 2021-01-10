import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/chats_service.dart';
import '../widgets/insta_app_bar.dart';

class NewChatPage extends StatefulWidget {
  static const routeName = '/newchat';

  @override
  _NewChatPageState createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage>
    with SingleTickerProviderStateMixin {
  Auth auth;
  TabController tabController;
  FocusNode createFocusNode, joinFocusNode;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    createFocusNode = FocusNode();
    joinFocusNode = FocusNode();

    tabController.addListener(() {
      switch (tabController.index) {
        case 0:
          createFocusNode.requestFocus();
          break;
        case 1:
          joinFocusNode.requestFocus();
          break;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    auth = Provider.of<Auth>(context, listen: false);
  }

  void _signOut(BuildContext context) {
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InstaAppBar(
        title: 'New Chat',
        actions: [
          FlatButton(
            onPressed: () => _signOut(context),
            child: Text('Logout'),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          TabBar(
            controller: tabController,
            tabs: <Widget>[
              Tab(text: 'Create'),
              Tab(text: 'Join'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                CreateChat(createFocusNode),
                JoinChat(joinFocusNode),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CreateChat extends StatefulWidget {
  final FocusNode focusNode;

  CreateChat(this.focusNode);

  @override
  _CreateChatState createState() => _CreateChatState();
}

class _CreateChatState extends State<CreateChat> {
  final createChatForm = GlobalKey<FormState>();
  String address;
  String chatName;
  FocusNode nameNode;

  @override
  void initState() {
    super.initState();
    nameNode = FocusNode();
  }

  void createChat(context) async {
    if (!createChatForm.currentState.validate()) return;
    createChatForm.currentState.save();

    Provider.of<ChatsService>(context, listen: false)
        .createChat(address, chatName);

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: createChatForm,
        child: ListView(
          primary: false,
          shrinkWrap: true,
          children: <Widget>[
            TextFormField(
              autofocus: true,
              focusNode: widget.focusNode,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Chat address",
              ),
              validator: (value) {
                value = value.trim();

                final spaces = RegExp(r'\s');
                if (value.length == 0) return "Enter Chat address";

                if (spaces.hasMatch(value))
                  return "Chat address cannot have spaces";

                if (!RegExp(r'^\w+$').hasMatch(value))
                  return "Chat address must only contain letters, numbers and _";

                if (!value.startsWith(RegExp(r'[A-Za-z]')))
                  return "Chat address must start with a letter";

                return null;
              },
              onSaved: (value) {
                address = value.trim().toLowerCase();
              },
              onFieldSubmitted: (_) => nameNode.requestFocus(),
            ),
            SizedBox(height: 15),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Chat Name",
              ),
              focusNode: nameNode,
              validator: (value) {
                if (value.trim().length == 0) return "Enter chat name";
                return null;
              },
              onSaved: (value) {
                chatName = value.trim();
              },
            ),
            SizedBox(height: 10),
            RaisedButton(
              onPressed: () => createChat(context),
              child: Text('Create Chat'),
            ),
          ],
        ),
      ),
    );
  }
}

class JoinChat extends StatefulWidget {
  final FocusNode focusNode;

  JoinChat(this.focusNode);

  @override
  _JoinChatState createState() => _JoinChatState();
}

class _JoinChatState extends State<JoinChat> {
  var joinChatForm = GlobalKey<FormState>();
  String address;

  void joinChat(context) async {
    if (!joinChatForm.currentState.validate()) return;
    joinChatForm.currentState.save();

    Provider.of<ChatsService>(context, listen: false).joinChat(address);

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: joinChatForm,
        child: ListView(
          primary: false,
          shrinkWrap: true,
          children: <Widget>[
            TextFormField(
              focusNode: widget.focusNode,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Chat address",
              ),
              validator: (value) {
                value = value.trim();

                final spaces = new RegExp(r'\s');
                if (spaces.hasMatch(value))
                  return "Chat address cannot have spaces";
                if (value.length == 0) return "Enter chat address";
                return null;
              },
              onSaved: (value) {
                address = value.trim().toLowerCase();
              },
            ),
            SizedBox(height: 10),
            RaisedButton(
              onPressed: () => joinChat(context),
              child: Text('Join Chat'),
            ),
          ],
        ),
      ),
    );
  }
}
