import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
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
                CreateRoom(createFocusNode),
                JoinRoom(joinFocusNode),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CreateRoom extends StatefulWidget {
  final FocusNode focusNode;

  CreateRoom(this.focusNode);

  @override
  _CreateRoomState createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  final createRoomForm = GlobalKey<FormState>();
  String roomId;
  String roomName;
  FocusNode nameNode;

  @override
  void initState() {
    super.initState();
    nameNode = FocusNode();
  }

  void createRoom(context) async {
    if (!createRoomForm.currentState.validate()) return;
    createRoomForm.currentState.save();

    // final chats = await Firestore.instance
    //     .collection('chat')
    //     .where('id', isEqualTo: roomId)
    //     .limit(1)
    //     .getDocuments();

    // if (chats.documents.length > 0)
    //   return showAlert(context, 'Room with this ID already exists');

    // await Firestore.instance.collection('chat').add({
    //   'id': roomId,
    //   'name': roomName,
    //   'imageUrl': 'https://picsum.photos/id/327/120',
    // });

    // final auth = Provider.of<auth>(context, listen: false);

    // await Firestore.instance
    //     .collection('user')
    //     .document(auth.account.id)
    //     .collection('chat')
    //     .add({'id': roomId});

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: createRoomForm,
        child: ListView(
          primary: false,
          shrinkWrap: true,
          children: <Widget>[
            TextFormField(
              autofocus: true,
              focusNode: widget.focusNode,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Room id",
              ),
              validator: (value) {
                value = value.trim();

                final spaces = new RegExp(r'\s');
                if (spaces.hasMatch(value)) return "Room id cannot have spaces";
                if (value.length == 0) return "Enter room id";
                return null;
              },
              onSaved: (value) {
                roomId = value.trim().toLowerCase();
              },
              onFieldSubmitted: (_) => nameNode.requestFocus(),
            ),
            SizedBox(height: 15),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Room Name",
              ),
              focusNode: nameNode,
              validator: (value) {
                if (value.trim().length == 0) return "Enter room name";
                return null;
              },
              onSaved: (value) {
                roomName = value.trim();
              },
            ),
            SizedBox(height: 10),
            RaisedButton(
              onPressed: () => createRoom(context),
              child: Text('Create Room'),
            ),
          ],
        ),
      ),
    );
  }
}

class JoinRoom extends StatefulWidget {
  final FocusNode focusNode;

  JoinRoom(this.focusNode);

  @override
  _JoinRoomState createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
  var joinRoomForm = GlobalKey<FormState>();
  String roomId;

  void joinRoom(context) async {
    if (!joinRoomForm.currentState.validate()) return;
    joinRoomForm.currentState.save();

    // final chats = await Firestore.instance
    //     .collection('chat')
    //     .where('id', isEqualTo: roomId)
    //     .limit(1)
    //     .getDocuments();
    // if (chats.documents.length == 0)
    //   return showAlert(context, 'Room not found');

    // final auth = Provider.of<auth>(context, listen: false);
    // await Firestore.instance
    //     .collection('user')
    //     .document(auth.account.id)
    //     .collection('chat')
    //     .add({'id': roomId});

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: joinRoomForm,
        child: ListView(
          primary: false,
          shrinkWrap: true,
          children: <Widget>[
            TextFormField(
              focusNode: widget.focusNode,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Room Id",
              ),
              validator: (value) {
                value = value.trim();

                final spaces = new RegExp(r'\s');
                if (spaces.hasMatch(value)) return "Room id cannot have spaces";
                if (value.length == 0) return "Enter room id";
                return null;
              },
              onSaved: (value) {
                roomId = value.trim().toLowerCase();
              },
            ),
            SizedBox(height: 10),
            RaisedButton(
              onPressed: () => joinRoom(context),
              child: Text('Join Room'),
            ),
          ],
        ),
      ),
    );
  }
}
