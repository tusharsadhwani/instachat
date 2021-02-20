import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../widgets/insta_app_bar.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _handleSignIn() async {
    final auth = Provider.of<Auth>(context, listen: false);
    await auth.signIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InstaAppBar(title: 'Login'),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleSignIn,
          child: Text('Login'),
        ),
      ),
    );
  }
}
