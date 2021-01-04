import 'dart:convert';

import './message.dart';

class UpdateType {
  static const MESSAGE = 'MESSAGE', LIKE = 'LIKE';
}

class Update {
  String type;
  Message message;
  String messageId;

  Update({this.message, this.messageId})
      : type = message != null ? UpdateType.MESSAGE : UpdateType.LIKE;

  Update.fromJson(String data) {
    final update = jsonDecode(data);
    if (update['message'] != null) {
      type = UpdateType.MESSAGE;
      message = Message.fromMap(update['message']);
    } else {
      type = UpdateType.LIKE;
      messageId = update['msgid'];
    }
  }

  String toJson() {
    return jsonEncode({
      'type': type,
      'message': message.toMap(),
      'messageId': messageId,
    });
  }
}
