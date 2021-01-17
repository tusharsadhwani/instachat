import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import './auth_service.dart';
import '../models/chat.dart';

class ChatsService extends ChangeNotifier {
  final Dio dio;
  final Auth auth;
  final Options authOptions;
  List<Chat> _chats = [];

  List<Chat> get chats => _chats;

  ChatsService(this.auth)
      : dio = new Dio(),
        authOptions = Options(headers: auth.headers) {
    this.updateChats();
  }

  Future<void> updateChats() async {
    final userId = auth.user.id;
    final response = await dio.get(
      "http://${auth.domain}/user/$userId/chat",
      options: authOptions,
    );
    _chats = response.data.map<Chat>((c) => Chat.fromMap(c)).toList();
    notifyListeners();
  }

  Future<void> createChat(String address, String name) async {
    await dio.post(
      "http://${auth.domain}/chat",
      options: authOptions,
      data: {
        'address': address,
        'name': name,
      },
    );
    updateChats();
  }

  Future<void> joinChat(String address) async {
    await dio.post(
      "http://${auth.domain}/chat/$address",
      options: authOptions,
    );
    updateChats();
  }
}
