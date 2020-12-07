import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../models/auth_user.dart';
import '../models/chat.dart';

class ChatsService extends ChangeNotifier {
  final Dio dio;
  final AuthUser authUser;
  List<Chat> _chats = [];

  List<Chat> get chats => _chats;

  ChatsService(this.authUser) : dio = new Dio() {
    this.updateChats();
  }

  Future<void> updateChats() async {
    final userId = authUser.user.id;
    print('userId: $userId');
    final response = await dio.get(
      "http://192.168.29.76:3000/user/$userId/chat",
      options: Options(headers: {"Authorization": "Bearer ${authUser.jwt}"}),
    );
    print('response: ${response.data}');
    _chats = response.data.map<Chat>((c) => Chat.fromMap(c)).toList();
    notifyListeners();
  }
}
