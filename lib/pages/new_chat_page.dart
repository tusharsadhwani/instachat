import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/auth_user.dart';
import '../widgets/insta_app_bar.dart';
import 'login_page.dart';

class NewChatPage extends StatefulWidget {
  @override
  _NewChatPageState createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage>
    with SingleTickerProviderStateMixin {
  AuthUser authUser;
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authUser = Provider.of<AuthUser>(context, listen: false);
  }

  void _signOut(BuildContext context) {
    authUser.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
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
              children: [CreateRoom(), JoinRoom()],
            ),
          ),
        ],
      ),
    );
  }
}

class CreateRoom extends StatefulWidget {
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

    final chats = await Firestore.instance
        .collection('chat')
        .where('id', isEqualTo: roomId)
        .limit(1)
        .getDocuments();
    if (chats.documents.length > 0)
      return showAlert(context, 'Room with this ID alredy exists');

    await Firestore.instance.collection('chat').add({
      'id': roomId,
      'name': roomName,
      'imageUrl': 'https://picsum.photos/id/327/120',
    });

    final authUser = Provider.of<AuthUser>(context, listen: false);

    // TODO: might want to move this to a cloud function
    await Firestore.instance
        .collection('user')
        .document(authUser.account.id)
        .collection('chat')
        .add({'id': roomId});

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
                roomId = value.trim();
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
  @override
  _JoinRoomState createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
  var joinRoomForm = GlobalKey<FormState>();
  String roomName;

  void joinRoom(context) async {
    if (!joinRoomForm.currentState.validate()) return;

    joinRoomForm.currentState.save();
    // final db = Provider.of<Database>(context, listen: false);
    // final joined = await db.joinRoom(name: userName, roomCode: roomCode);

    // if (joined)
    //   Navigator.of(context).pushReplacementNamed(SudokuScreen.routeName);
    // else
    //   showAlert(context, 'The room is already full.');
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
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Room Name",
              ),
              validator: (value) {
                if (value.trim().length == 0) return "Enter room name";
                return null;
              },
              onSaved: (value) {
                roomName = value;
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

void showAlert(BuildContext context, String s) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Error"),
      content: Text(
        s,
        style: TextStyle(color: Colors.black),
      ),
    ),
  );
}
