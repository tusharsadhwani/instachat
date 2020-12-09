import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:instachat/models/auth_user.dart';
import 'package:instachat/models/message.dart';

class MessageService extends ChangeNotifier {
  final Dio dio;
  final AuthUser authUser;
  final int chatId;

  List<Message> _messages = [];

  List<Message> get messages => _messages;

  MessageService(this.authUser, this.chatId) : dio = new Dio() {
    this.updateMessages();
  }

  Future<void> updateMessages() async {
    final response = await dio.get(
      "http://10.0.2.2:3000/chat/$chatId/message",
      options: Options(headers: {"Authorization": "Bearer ${authUser.jwt}"}),
    );
    _messages = response.data.map<Message>((m) => Message.fromMap(m)).toList();
    notifyListeners();
  }
}
