import '../models/chat.dart';
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
  Future<Response> getchatByID(@Bind.path('id') int id) async {
    final chatQuery = Query<Chat>(context)..where((h) => h.id).equalTo(id);

    final chat = await chatQuery.fetchOne();

    if (chat == null) {
      return Response.notFound();
    }
    return Response.ok(chat);
  }

  @Operation.post()
  Future<Response> createHero(@Bind.body(ignore: ["id"]) Chat inputChat) async {
    final query = Query<Chat>(context)..values = inputChat;

    final insertedChat = await query.insert();

    return Response.ok(insertedChat);
  }
}
