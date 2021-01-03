import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../models/auth_user.dart';
import '../models/chat.dart';

class ChatsService extends ChangeNotifier {
  final Dio dio;
  final Auth auth;
  List<Chat> _chats = [];

  List<Chat> get chats => _chats;

  ChatsService(this.auth) : dio = new Dio() {
    this.updateChats();
  }

  Future<void> updateChats() async {
    final userId = auth.user.id;
    final response = await dio.get(
      "${auth.url}/user/$userId/chat",
      options: Options(headers: {"Authorization": "Bearer ${auth.jwt}"}),
    );
    _chats = response.data.map<Chat>((c) => Chat.fromMap(c)).toList();
    notifyListeners();
  }
}
