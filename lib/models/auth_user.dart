import 'package:google_sign_in/google_sign_in.dart';

class AuthUser {
  GoogleSignIn _googleSignIn;
  GoogleSignInAccount _account;

  GoogleSignInAccount get account => _account;

  AuthUser() {
    _googleSignIn = GoogleSignIn();
  }

  Future<void> trySignInSilently() async {
    _account = await _googleSignIn.signInSilently();
  }

  Future<void> signIn() async {
    _account = await _googleSignIn.signIn();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _account = null;
  }
}
