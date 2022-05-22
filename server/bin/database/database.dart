import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';

import '../config.dart';
import '../server.dart';

class Database {
  static final Database _instance = Database._internal();
  factory Database() => _instance;
  late final LazyBox<dynamic> _secretsBox;

  Database._internal() {
    init();
  }

  init() async {
    final config = Config();
    final path = Directory(config.dataDirectory);
    final dataDirExists = await path.exists();
    if (!dataDirExists) {
      await path.create();
    }
    Hive.init(config.dataDirectory);
  }

  Future<dynamic> get(String key) async {
    return _secretsBox.get(key);
  }

  Future<void> put(String key, dynamic value) async {
    return _secretsBox.put(key, value);
  }

  Future<void> unlockSecrets(String password) async {
    List<int> bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    final key = hash.bytes;
    _secretsBox =
        await Hive.openLazyBox('secrets', encryptionCipher: HiveAesCipher(key));
  }
}
