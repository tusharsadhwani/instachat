import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:instachat/models/auth_user.dart';
import 'package:instachat/models/message.dart';

class MessageService extends ChangeNotifier {
  final Dio dio;
  final Auth auth;
  final int chatId;

  List<Message> _messages = [];

  List<Message> get messages => _messages;

  WebSocket _ws;
  WebSocket get ws => _ws;

  MessageService(this.auth, this.chatId) : dio = new Dio() {
    this.updateMessages();
  }

  Future<void> updateMessages() async {
    final response = await dio.get(
      "${auth.url}/chat/$chatId/message",
      options: Options(headers: {"Authorization": "Bearer ${auth.jwt}"}),
    );
    _messages = response.data.map<Message>((m) => Message.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> connectWebsocket() async {
    _ws = await WebSocket.connect(
      'ws://192.168.29.76:3000/ws/${auth.user.id}/chat/$chatId',
      headers: {"Authorization": "Bearer ${auth.jwt}"},
    );

    try {
      if (ws?.readyState == WebSocket.open) {
        ws.add('client connected');
        ws.listen(
          (data) {
            _messages.add(Message.fromMap(data));
            notifyListeners();
          },
          onDone: () => print('[+]Done :)'),
          onError: (err) => print('[!]Error -- ${err.toString()}'),
          cancelOnError: true,
        );
      } else
        print('[!]Connection Denied');
    } catch (err) {
      print('err: $err');
    }
  }
}
