import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../database/database.dart';

late final Database db;

Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

Future<Response> _openssl(Request request) async {
  final resp = await Process.run("openssl", ["version"]);
  return Response.ok('${resp.stdout}\n');
}

Future<Response> _storeSecret(Request request) async {
  await db.put("k1", "test-123");
  return Response.ok('works \n');
}

Future<Response> _getSecret(Request request) async {
  final secret = await db.get("k1");
  return Response.ok('$secret \n');
}

Future<Response> _unlockSecrets(Request request) async {
  await db.unlockSecrets('MySecret-password');
  return Response.ok("ok");
}

class Api {
  Api() {
    db = Database();
  }
  Router get router {
    final router = Router();

    router
      ..get('/', _rootHandler)
      ..get('/unlock', _unlockSecrets)
      ..get('/echo/<message>', _echoHandler)
      ..get('/store', _storeSecret)
      ..get('/openssl', _openssl)
      ..get('/get', _getSecret);
    // This nested catch-all, will only catch /api/.* when mounted above.
    // Notice that ordering if annotated handlers and mounts is significant.
    router.all('/<ignored|.*>', (Request request) => Response.notFound('null'));

    return router;
  }
}
