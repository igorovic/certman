import 'dart:io';

import 'package:hive/hive.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shelf_static/shelf_static.dart';

import 'api/api.dart';
import 'config.dart';

// Configure routes.
final _router = Router()
  ..mount("/api/", Api().router)
  ..get(
      "/<ignored|.*>",
      createStaticHandler('web',
          defaultDocument: 'index.html',
          listDirectories: false,
          serveFilesOutsidePath: false));

void main(List<String> args) async {
  final config = Config();

  List<int> bytes = utf8.encode('MySecret-password');
  final hash = sha256.convert(bytes);
  final key = hash.bytes;

  //Hive.init(path.path);
  //secretsBox =
  //    await Hive.openLazyBox('secrets', encryptionCipher: HiveAesCipher(key));

  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final pipeline = Pipeline().addMiddleware(logRequests());
  final handler = pipeline.addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port =
      int.parse(Platform.environment['PORT'] ?? config.serverPort.toString());
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
