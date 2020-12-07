import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserData {
  final String name;
  final int id;
  UserData.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        name = data['name'];
}

class AuthUser extends ChangeNotifier {
  final GoogleSignIn _googleSignIn;
  final Dio _dio;
  AuthUser()
      : _googleSignIn = GoogleSignIn(),
        _dio = Dio();

  GoogleSignInAccount _account;
  GoogleSignInAccount get account => _account;

  String _jwt = "";
  String get jwt => _jwt;
  UserData _user;
  UserData get user => _user;

  Future<void> getJWT(String idToken) async {
    final response =
        await _dio.post("http://192.168.29.76:3000/login", data: idToken);
    _jwt = response.data['token'];
    _user = UserData.fromMap(response.data['user']);
  }

  Future<void> trySignInSilently() async {
    try {
      _account = await _googleSignIn.signInSilently();
      final auth = await _account.authentication;
      await getJWT(auth.idToken);
      notifyListeners();
    } catch (e) {}
  }

  Future<void> signIn() async {
    _account = await _googleSignIn.signIn();
    final auth = await _account.authentication;
    await getJWT(auth.idToken);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _account = null;
    notifyListeners();
  }
}
