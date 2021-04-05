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
      : dio = Dio(),
        authOptions = Options(headers: auth.headers) {
    this.updateChats();
  }

  Future<void> updateChats() async {
    final userId = auth.user.id;
    final response = await dio.get(
      "https://${auth.domain}/user/$userId/chat",
      options: authOptions,
    );
    _chats = response.data.map<Chat>((c) => Chat.fromMap(c)).toList();
    notifyListeners();
  }

  Future<String> createChat(String address, String name) async {
    try {
      await dio.post(
        "https://${auth.domain}/chat",
        options: authOptions,
        data: {
          'address': address,
          'name': name,
        },
      );
    } on DioError catch (e) {
      return e.response.data;
    }
    updateChats();
    return null;
  }

  Future<String> joinChat(String address) async {
    try {
      await dio.post(
        "https://${auth.domain}/chat/$address",
        options: authOptions,
      );
    } on DioError catch (e) {
      return e.response.data;
    }
    updateChats();
    return null;
  }
}
