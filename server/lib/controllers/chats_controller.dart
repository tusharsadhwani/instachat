import '../models/chat.dart';
import '../models/user.dart';
import '../server.dart';

class ChatsController extends ResourceController {
  ChatsController(this.context);
  final ManagedContext context;

  @Operation.get()
  Future<Response> getChats() async {
    // TODO: assuming default user for now
    final chatQuery = Query<Chat>(context)
      ..join(object: (chat) => chat.owner)
      ..join(set: (chat) => chat.userChats)
          .join(object: (uc) => uc.user)
          .where((user) => user.id)
          .equalTo(1);

    final chats = await chatQuery.fetch();
    chats.forEach((chat) => chat.backing.removeProperty("userChats"));
    return Response.ok(chats);
  }

  @Operation.get('id')
  Future<Response> getChatByID(@Bind.path('id') int id) async {
    final chatQuery = Query<Chat>(context)..where((h) => h.id).equalTo(id);

    final chat = await chatQuery.fetchOne();

    if (chat == null) {
      return Response.notFound();
    }
    return Response.ok(chat);
  }

  @Operation.post()
  Future<Response> createChat(
      @Bind.body(ignore: ["id", "owner"]) Chat newChat) async {
    final chatQuery = Query<Chat>(context)..values = newChat;

    // TODO: assuming default user for now
    final userQuery = Query<User>(context)..where((u) => u.id).equalTo(1);
    final user = await userQuery.fetchOne();

    chatQuery.values.owner = user;
    final insertedChat = await chatQuery.insert();

    final userChat = Query<UserChat>(context);
    userChat.values.chat = insertedChat;
    userChat.values.user = user;

    await userChat.insert();

    return Response.ok(insertedChat);
  }
}
