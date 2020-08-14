import 'package:google_sign_in/google_sign_in.dart';

class AuthUser {
  final _googleSignIn = GoogleSignIn();
  GoogleSignInAccount account;

  AuthUser() {
    print('creating new auth user');
  }

  Future<void> trySignInSilently() async {
    account = await _googleSignIn.signInSilently();
  }

  Future<void> signIn() async {
    account = await _googleSignIn.signIn();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    account = null;
  }
}
