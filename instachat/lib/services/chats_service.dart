import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../services/auth_service.dart';
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
      "http://${auth.domain}/user/$userId/chat",
      options: Options(headers: {"Authorization": "Bearer ${auth.jwt}"}),
    );
    _chats = response.data.map<Chat>((c) => Chat.fromMap(c)).toList();
    notifyListeners();
  }

  Future<void> createChat(String id, String name) async {
    await dio.post(
      "http://${auth.domain}/chat",
      options: Options(headers: {"Authorization": "Bearer ${auth.jwt}"}),
      data: {
        'id': id,
        'name': name,
      },
    );
    updateChats();
  }
}
