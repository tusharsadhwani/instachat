import 'dart:convert';
import 'package:meta/meta.dart';

import './message.dart';

class UpdateType {
  static const MESSAGE = 'MESSAGE', LIKE = 'LIKE', UNLIKE = 'UNLIKE';
}

class Update {
  String type;
  Message message;
  String messageId;

  Update({@required this.type, this.message, this.messageId});

  Update.fromJson(String data) {
    final updateData = jsonDecode(data);
    type = updateData['type'];
    message = updateData['message'] == null
        ? null
        : Message.fromMap(updateData['message']);
    messageId = updateData['messageId'];
  }

  String toJson() {
    return jsonEncode({
      'type': type,
      'message': message?.toMap() ?? null,
      'messageId': messageId,
    });
  }
}
