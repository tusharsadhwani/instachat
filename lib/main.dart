import 'package:flutter/material.dart';

import 'pages/chat_page.dart';
import 'pages/chats_page.dart';

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
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          bodyText2: TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ),
      routes: {
        '/': (_) => ChatsPage(),
        ChatPage.routeName: (_) => ChatPage(),
      },
      initialRoute: '/',
    );
  }
}
