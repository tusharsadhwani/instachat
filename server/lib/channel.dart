import 'package:aqueduct/managed_auth.dart';
import 'package:server/controllers/join_chat_controller.dart';

import 'controllers/chats_controller.dart';
import 'controllers/register_controller.dart';
import 'models/user.dart';
import 'server.dart';

class ServerChannel extends ApplicationChannel {
  ManagedContext context;
  AuthServer authServer;

  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final persistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
        "postgres", "password", "localhost", 5432, "instachat");

    context = ManagedContext(dataModel, persistentStore);

    final authStorage = ManagedAuthDelegate<User>(context);
    authServer = AuthServer(authStorage);
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router.route('/auth/token').link(() => AuthController(authServer));

    router.route("/chats[/:id]").link(() => ChatsController(context));
    router.route("/join[/:id]").link(() => JoinChatController(context));

    router
        .route('/register')
        .link(() => RegisterController(context, authServer));

    router.route('/example').linkFunction((request) async {
      return Response.ok({'key': 'value'});
    });

    return router;
  }
}
