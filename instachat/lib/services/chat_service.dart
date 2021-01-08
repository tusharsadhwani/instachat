import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import './auth_service.dart';
import '../models/message.dart';
import '../models/update.dart';

class ChatService extends ChangeNotifier {
  final Dio dio;
  final Auth auth;
  final int chatId;

  List<Message> _messages = [];
  int nextCursor = 0;
  bool allMessagesLoaded = false;

  List<Message> get messages => _messages;

  WebSocket _ws;
  WebSocket get ws => _ws;
  bool userSentNewMessage = false;

  ChatService(this.auth, this.chatId) : dio = new Dio() {
    this.updateMessages();
  }

  @override
  void dispose() {
    _ws?.close();
    super.dispose();
  }

  Future fetchMessages() async {
    final response = await dio.get(
      "http://${auth.domain}/chat/$chatId/message/$nextCursor",
      options: Options(headers: {"Authorization": "Bearer ${auth.jwt}"}),
    );
    nextCursor = response.data['next'];
    if (nextCursor == -1) allMessagesLoaded = true;

    final messageData = response.data['messages'];
    return messageData;
  }

  Future<void> updateMessages() async {
    final messageData = await fetchMessages();
    _messages = messageData.map<Message>((m) => Message.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> loadOlderMessages() async {
    final messageData = await fetchMessages();
    final newMessages =
        messageData.map<Message>((m) => Message.fromMap(m)).toList();
    _messages = [...newMessages, ..._messages];
    notifyListeners();
  }

  Future<void> connectWebsocket() async {
    _ws = await WebSocket.connect(
      'ws://${auth.domain}/ws/${auth.user.id}/chat/$chatId',
      headers: {"Authorization": "Bearer ${auth.jwt}"},
    );

    try {
      if (ws?.readyState == WebSocket.open) {
        ws.listen(
          (data) {
            final update = Update.fromJson(data);
            switch (update.type) {
              case UpdateType.MESSAGE:
                userSentNewMessage = update.message.senderId == auth.user.id;
                _messages.add(update.message);
                break;
              case UpdateType.LIKE:
                final message =
                    _messages.firstWhere((msg) => msg.id == update.messageId);
                message.liked = true;
                break;
            }
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

  Future<void> sendMessage(Message message) async {
    final update = Update(message: message);
    _ws.add(update.toJson());
  }

  void like(String messageId) {
    final update = Update(messageId: messageId);
    _ws.add(update.toJson());
  }
}
