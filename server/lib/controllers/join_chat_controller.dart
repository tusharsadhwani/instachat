import '../models/chat.dart';
import '../models/user.dart';
import '../server.dart';

class JoinChatController extends ResourceController {
  JoinChatController(this.context);
  final ManagedContext context;

  @Operation.post('id')
  Future<Response> joinChat(@Bind.path('id') int id) async {
    final chatQuery = Query<Chat>(context)
      ..where((chat) => chat.id).equalTo(id);
    final chat = await chatQuery.fetchOne();

    //TODO: check if chat exists

    //TODO: check if user is already in the chat, and look into composite keys

    final userChat = Query<UserChat>(context);
    userChat.values.chat = chat;

    // TODO: assuming default user for now
    final userQuery = Query<User>(context)..where((u) => u.id).equalTo(1);
    final user = await userQuery.fetchOne();
    userChat.values.user = user;

    await userChat.insert();

    return Response.ok(chat);
  }
}
