import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../models/auth_user.dart';
import '../models/chat.dart';

class ChatsService extends ChangeNotifier {
  final AuthUser authUser;
  List<Chat> _chats = [];

  List<Chat> get chats => _chats;

  ChatsService(this.authUser);

  Future<void> updateChats() async {
    final userChats = await Firestore.instance
        .collection('user')
        .document(authUser.account.id)
        .collection('chat')
        .getDocuments();

    final chatIds = userChats.documents.map((doc) => doc.data['id']).toList();

    // TODO: this could break for more than 10 chatIds
    if (chatIds.length > 0) {
      final chatDocs = await Firestore.instance
          .collection('chat')
          .where('id', whereIn: chatIds)
          .getDocuments();

      _chats = chatDocs.documents.map((d) => Chat.fromMap(d.data)).toList();
      notifyListeners();
    }
  }
}
