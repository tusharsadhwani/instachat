import 'package:flutter/material.dart';

import 'models/chat.dart';
import 'widgets/insta_app_bar.dart';
import 'widgets/search_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InstaChat',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        accentColor: Color.fromRGBO(54, 54, 54, 1),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(color: Color.fromRGBO(27, 27, 27, 1)),
        textTheme: TextTheme(
          headline6: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          bodyText1: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      home: MyHomePage(title: 'InstaChat'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final chats = <Chat>[
    Chat(id: '1', name: 'Test Log', imageUrl: 'https://i.pravatar.cc/50?img=2'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InstaAppBar(title: widget.title),
            SearchBar(),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 16),
              child: Text(
                'Messages',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (_, __) => SizedBox(height: 8),
                itemCount: chats.length,
                itemBuilder: (_, i) => InkWell(
                  onTap: () {},
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(chats[i].imageUrl),
                    ),
                    title: Text(chats[i].name),
                    subtitle: Text(
                      'Liked a message',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
