import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth_user.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    final authUser = Provider.of<AuthUser>(context, listen: false);
    await authUser.trySignInSilently();
    if (authUser.account == null)
      Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('helo'),
      ),
    );
  }
}
