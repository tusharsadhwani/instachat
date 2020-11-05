import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth_user.dart';
import '../widgets/insta_app_bar.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _handleSignIn() async {
    final authUser = Provider.of<AuthUser>(context, listen: false);
    await authUser.signIn();
    if (authUser.account != null)
      Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
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
