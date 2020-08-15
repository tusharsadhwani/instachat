import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/chats_page.dart';
import '../models/auth_user.dart';
import '../widgets/insta_app_bar.dart';
import '../helpers.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<void> _handleSignIn() async {
    final authUser = Provider.of<AuthUser>(context, listen: false);
    try {
      await authUser.signIn();
      if (authUser.account != null)
        Navigator.of(context).pushReplacementNamed(ChatsPage.routeName);
    } catch (error) {
      showAlert(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InstaAppBar(title: 'Login'),
      body: Center(
        child: RaisedButton(
          onPressed: _handleSignIn,
          child: Text('Login'),
        ),
      ),
    );
  }
}
