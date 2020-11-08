import 'controllers/chats_controller.dart';
import 'server.dart';

class ServerChannel extends ApplicationChannel {
  ManagedContext context;

  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final persistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
        "postgres", "password", "localhost", 5432, "instachat");

    context = ManagedContext(dataModel, persistentStore);
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router.route("/chats[/:id]").link(() => ChatsController(context));

    router.route('/example').linkFunction((request) async {
      return Response.ok({'key': 'value'});
    });

    return router;
  }
}
