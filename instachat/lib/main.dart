import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instachat/services/chats_service.dart';
import 'package:provider/provider.dart';

import './models/auth_user.dart';
import './pages/chats_page.dart';
import './pages/login_page.dart';
import './pages/new_chat_page.dart';
// import './pages/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final themeData = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    accentColor: Color.fromRGBO(84, 84, 84, 1),
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(color: Color.fromRGBO(36, 36, 36, 1)),
    buttonColor: Color.fromRGBO(36, 36, 36, 1),
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
        height: 1.3,
      ),
    ),
  );

  @override
  Widget build(BuildContext ctx) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );

    return ChangeNotifierProvider(
      create: (_) => AuthUser(),
      builder: (context, _) => Consumer<AuthUser>(
        builder: (_, authUser, __) {
          //TODO: Send the id token to backend and receive JWT, then log user in
          //TODO: Add a waiting state to authUser where you show a splash screen
          if (authUser.account != null) {
            return ChangeNotifierProvider(
              create: (_) => ChatsService(authUser),
              child: LoggedInApp(themeData: themeData),
            );
          }
          return LoggedOutApp(themeData: themeData);
        },
      ),
    );
  }
}

class LoggedInApp extends StatelessWidget {
  const LoggedInApp({
    Key key,
    @required this.themeData,
  }) : super(key: key);

  final ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InstaChat',
      theme: themeData,
      home: ChatsPage(),
      onGenerateRoute: (route) {
        switch (route.name) {
          case NewChatPage.routeName:
            return MaterialPageRoute<bool>(
              builder: (_) => NewChatPage(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => ChatsPage(),
            );
        }
      },
    );
  }
}

class LoggedOutApp extends StatelessWidget {
  final ThemeData themeData;

  const LoggedOutApp({Key key, this.themeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InstaChat',
      theme: themeData,
      home: LoginPage(),
    );
  }
}
