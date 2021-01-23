import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:google_sign_in/google_sign_in.dart';

class UserData {
  final int id;
  final String name;

  UserData.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        name = data['name'];
}

enum AuthState { WAITING, LOGGED_OUT, LOGGED_IN }

class Auth extends ChangeNotifier {
  final GoogleSignIn _googleSignIn;
  final Dio _dio;
  Auth()
      : _googleSignIn = GoogleSignIn(),
        _dio = Dio() {
    trySignInSilently();
  }

  final domain = kReleaseMode ? dotenv.env['DOMAIN'] : 'localhost:5555';
  final s3Url = dotenv.env['S3_URL'];

  GoogleSignInAccount _account;
  GoogleSignInAccount get account => _account;

  String _jwt = "";
  String get jwt => _jwt;
  Map<String, dynamic> get headers => {"Authorization": "Bearer $jwt"};

  UserData _user;
  UserData get user => _user;

  AuthState _state = AuthState.WAITING;
  AuthState get state => _state;

  Future<void> getJWT(String idToken) async {
    log(idToken);
    try {
      final response = await _dio.post("http://$domain/login", data: idToken);
      _jwt = response.data['token'];
      _user = UserData.fromMap(response.data['user']);
      _state = AuthState.LOGGED_IN;
    } catch (e) {
      _jwt = "";
      _user = null;
      _state = AuthState.LOGGED_OUT;
    }
    notifyListeners();
  }

  Future<void> trySignInSilently() async {
    try {
      _account = await _googleSignIn.signInSilently();
      final auth = await _account.authentication;
      await getJWT(auth.idToken);
    } catch (e) {
      _state = AuthState.LOGGED_OUT;
      notifyListeners();
    }
  }

  Future<void> signIn() async {
    _state = AuthState.WAITING;
    notifyListeners();

    _account = await _googleSignIn.signIn();
    if (account == null) {
      _state = AuthState.LOGGED_OUT;
      notifyListeners();
      return;
    }

    final auth = await _account.authentication;
    await getJWT(auth.idToken);
  }

  Future<void> signOut() async {
    _state = AuthState.WAITING;
    notifyListeners();

    await _googleSignIn.signOut();
    _account = null;
    _state = AuthState.LOGGED_OUT;
    notifyListeners();
  }
}
