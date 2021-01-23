import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:provider/provider.dart';

import './pages/chats_page.dart';
import './pages/login_page.dart';
import './pages/new_chat_page.dart';
import './pages/splash_screen.dart';
import './services/auth_service.dart';
import './services/chats_service.dart';

void main() async {
  await dotenv.load();
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
      create: (_) => Auth(),
      builder: (context, _) => Consumer<Auth>(
        builder: (_, auth, __) {
          switch (auth.state) {
            case AuthState.LOGGED_IN:
              return ChangeNotifierProvider(
                create: (_) => ChatsService(auth),
                child: LoggedInApp(themeData: themeData),
              );
            case AuthState.LOGGED_OUT:
              return LoggedOutApp(themeData: themeData);
            case AuthState.WAITING:
            default:
              return MaterialApp(
                theme: themeData,
                home: SplashScreen(),
              );
          }
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
      initialRoute: '/',
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

class LoggedOutApp extends StatefulWidget {
  final ThemeData themeData;

  const LoggedOutApp({Key key, this.themeData}) : super(key: key);

  @override
  _LoggedOutAppState createState() => _LoggedOutAppState();
}

class _LoggedOutAppState extends State<LoggedOutApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InstaChat',
      theme: widget.themeData,
      home: LoginPage(),
    );
  }
}
