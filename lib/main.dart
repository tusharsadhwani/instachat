import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import './models/auth_user.dart';
import './pages/chats_page.dart';
import './pages/login_page.dart';
import './pages/new_chat_page.dart';
import './pages/splash_screen.dart';

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
          if (authUser.account != null) {
            return MaterialApp(
              key: ValueKey('Logged In'),
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
          return MaterialApp(
            key: ValueKey('Logged Out'),
            title: 'InstaChat',
            theme: themeData,
            routes: {
              '/': (_) => SplashScreen(),
              LoginPage.routeName: (_) => LoginPage(),
            },
            initialRoute: '/',
          );
        },
      ),
    );
  }
}
