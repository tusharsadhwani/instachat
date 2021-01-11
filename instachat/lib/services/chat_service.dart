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

  ChatService(this.auth, this.chatId) : dio = new Dio() {
    this.loadCachedMessages();
  }

  List<Message> _messages = [];
  List<Message> get messages => _messages;
  List<Message> _oldMessages = [];
  List<Message> get oldMessages => _oldMessages;

  bool loadingOlderMessages = false;
  bool allOlderMessagesLoaded = false;
  int prevCursor = 0;

  bool loadingNewerMessages = false;
  bool allNewerMessagesLoaded = false;
  int nextCursor = 0;

  WebSocket _ws;
  WebSocket get ws => _ws;

  bool latestMessagesLoaded = false;
  bool userSentNewMessage = false;

  @override
  void dispose() {
    _ws?.close();
    super.dispose();
  }

  Future<void> loadCachedMessages() async {
    // TODO: implement actual caching and cache loading
    // TODO: modify prevCursor and nextCursor based on cached values
    _messages = List<Message>.generate(
      20,
      (i) =>
          Message(senderId: 0, senderName: 'ok', content: 'Cached message $i'),
    );
  }

  Future<void> loadOlderMessages() async {
    loadingOlderMessages = true;

    final response = await dio.get(
      "http://${auth.domain}/chat/$chatId/message/old/$prevCursor",
      options: Options(headers: {"Authorization": "Bearer ${auth.jwt}"}),
    );
    prevCursor = response.data['next'];
    if (prevCursor == -1) allOlderMessagesLoaded = true;

    final messageData = response.data['messages'];
    final moreMessages =
        messageData.map<Message>((m) => Message.fromMap(m)).toList();
    _oldMessages.addAll(moreMessages);

    loadingOlderMessages = false;
    notifyListeners();
  }

  Future<void> loadNewerMessages() async {
    loadingNewerMessages = true;

    final response = await dio.get(
      "http://${auth.domain}/chat/$chatId/message/$nextCursor",
      options: Options(headers: {"Authorization": "Bearer ${auth.jwt}"}),
    );
    nextCursor = response.data['next'];
    if (nextCursor == -1) allNewerMessagesLoaded = true;

    final messageData = response.data['messages'];
    final moreMessages =
        messageData.map<Message>((m) => Message.fromMap(m)).toList();
    _messages.addAll(moreMessages);

    loadingNewerMessages = false;
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
                if (latestMessagesLoaded) _messages.add(update.message);
                break;
              case UpdateType.LIKE:
                final message = _messages.firstWhere(
                  (msg) => msg.id == update.messageId,
                  orElse: () => _oldMessages.firstWhere(
                    (msg) => msg.id == update.messageId,
                  ),
                );
                if (message != null) message.liked = true;
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

  Future<void> jumpToLatestMessages() async {
    latestMessagesLoaded = true;

    _oldMessages = [];
    prevCursor = 0;
    _messages = [];
    nextCursor = 0;
    await loadNewerMessages();
    notifyListeners();
  }
}
