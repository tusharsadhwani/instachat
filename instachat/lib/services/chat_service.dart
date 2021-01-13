import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import './auth_service.dart';
import '../models/message.dart';
import '../models/update.dart';
import '../services/message_cache.dart';

class ChatService extends ChangeNotifier {
  final Dio dio;
  final Auth auth;
  final int chatId;

  ChatService(this.auth, this.chatId) : dio = new Dio();

  List<Message> _messages = [];
  List<Message> get messages => _messages;
  List<Message> _oldMessages = [];
  List<Message> get oldMessages => _oldMessages;

  bool loadingOlderMessages = false;
  int prevCursor = 0;
  bool get allOlderMessagesLoaded => prevCursor == -1;

  bool loadingNewerMessages = false;
  int nextCursor = 0;
  bool get allNewerMessagesLoaded => nextCursor == -1;

  WebSocket _ws;
  WebSocket get ws => _ws;

  bool userSentNewMessage = false;

  MessageCache cache;

  Future<void> initialize() async {
    await loadCachedMessages();
  }

  @override
  void dispose() {
    _ws?.close();
    cache.save(filename: '${auth.user.id}_$chatId.json');
    super.dispose();
  }

  Future<void> loadCachedMessages() async {
    final docDir = await getApplicationDocumentsDirectory();
    final cacheFile =
        File(path.join(docDir.path, '${auth.user.id}_$chatId.json'));

    if (cacheFile.existsSync()) {
      final cacheJson = cacheFile.readAsStringSync();
      final cacheData = jsonDecode(cacheJson);
      cache = MessageCache.fromMap(cacheData);
      _messages = cache.messages.toList();
      prevCursor = cache.top == 1 ? -1 : cache.top - 1;
      nextCursor = cache.bottom + 1;
      print('loaded messages ${cache.top} to ${cache.bottom} from cache');
      notifyListeners();
    } else {
      cache = MessageCache();
      prevCursor = -1;
      jumpToLatestMessages();
    }
  }

  Future<void> saveCache() async {
    await cache.save(filename: '${auth.user.id}_$chatId.json');
  }

  Future<void> loadOlderMessages() async {
    loadingOlderMessages = true;

    final response = await dio.get(
      "http://${auth.domain}/chat/$chatId/oldmessage/$prevCursor",
      options: Options(headers: {"Authorization": "Bearer ${auth.jwt}"}),
    );
    prevCursor = response.data['next'];

    final messageData = response.data['messages'];
    List<Message> moreMessages =
        messageData.map<Message>((m) => Message.fromMap(m)).toList();
    _oldMessages.addAll(moreMessages);

    if (!cache.full) {
      moreMessages.forEach((m) => cache.pushFirst(m));
      print(
          'added message ${moreMessages.last.index} to ${moreMessages.first.index} to the top of cache');
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadingOlderMessages = false;
    });
    notifyListeners();
  }

  Future<void> loadNewerMessages() async {
    loadingNewerMessages = true;

    final response = await dio.get(
      "http://${auth.domain}/chat/$chatId/message/$nextCursor",
      options: Options(headers: {"Authorization": "Bearer ${auth.jwt}"}),
    );
    nextCursor = response.data['next'];

    final messageData = response.data['messages'];
    List<Message> moreMessages =
        messageData.map<Message>((m) => Message.fromMap(m)).toList();
    _messages.addAll(moreMessages);

    moreMessages.forEach((m) => cache.pushLast(m));
    if (moreMessages.isNotEmpty)
      print(
          'added message ${moreMessages.first.index} to ${moreMessages.last.index} to the cache');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadingNewerMessages = false;
    });
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
                if (allNewerMessagesLoaded) {
                  _messages.add(update.message);
                  cache.pushLast(update.message);
                  print('added ${update.message.index} to cache');
                }
                break;
              case UpdateType.LIKE:
                final message = _messages.firstWhere(
                  (msg) => msg.id == update.messageId,
                  orElse: () => _oldMessages.firstWhere(
                    (msg) => msg.id == update.messageId,
                  ),
                );
                if (message != null) {
                  message.liked = true;
                  final cachedMsg = cache.messages.firstWhere(
                    (msg) => msg.id == update.messageId,
                  );
                  if (cachedMsg != null) {
                    cachedMsg.liked = true;
                    print('liked message ${cachedMsg.index} in cache');
                  }
                }
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
    _oldMessages = [];
    nextCursor = -1;

    // TODO: empty message cache (for now)
    final response = await dio.get(
      "http://${auth.domain}/chat/$chatId/oldmessage",
      options: Options(headers: {"Authorization": "Bearer ${auth.jwt}"}),
    );
    final _next = response.data['next'];

    final messageData = response.data['messages'];
    List<Message> latestMessages =
        messageData.map<Message>((m) => Message.fromMap(m)).toList();

    _messages = latestMessages.reversed.toList();
    _messages.forEach((m) => cache.pushLast(m));
    print(
        'added message ${_messages.first.index} to ${_messages.last.index} to the cache');

    if (_next == -1) {
      prevCursor = -1;
    } else {
      prevCursor = _messages[0].index - 1;
    }
    notifyListeners();
  }
}
