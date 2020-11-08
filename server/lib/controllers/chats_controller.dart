import '../models/chat.dart';
import '../models/user.dart';
import '../server.dart';

class ChatsController extends ResourceController {
  ChatsController(this.context);
  final ManagedContext context;

  @Operation.get()
  Future<Response> getChats() async {
    final chatQuery = Query<Chat>(context);
    final chats = await chatQuery.fetch();

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
  Future<Response> createChat(@Bind.body(ignore: ["id"]) Chat newChat) async {
    final query = Query<Chat>(context)..values = newChat;

    final insertedChat = await query.insert();

    final userChat = Query<UserChat>(context);
    userChat.values.chat = insertedChat;

    // assuming default user for now
    final userQuery = Query<User>(context)..where((u) => u.id).equalTo(1);
    final user = await userQuery.fetchOne();
    userChat.values.user = user;

    await userChat.insert();

    return Response.ok(insertedChat);
  }
}
