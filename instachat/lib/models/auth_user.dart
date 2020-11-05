import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthUser extends ChangeNotifier {
  GoogleSignIn _googleSignIn;
  GoogleSignInAccount _account;

  GoogleSignInAccount get account => _account;

  AuthUser() {
    _googleSignIn = GoogleSignIn();
  }

  Future<void> trySignInSilently() async {
    _account = await _googleSignIn.signInSilently();
    notifyListeners();
  }

  Future<void> signIn() async {
    _account = await _googleSignIn.signIn();
    notifyListeners();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _account = null;
    notifyListeners();
  }
}
