import 'dart:io';

import 'package:yaml/yaml.dart';

class Config {
  static final Config _instance = Config._internal();

  static final configFile = new File("./config.yaml");
  static late final Map config;

  factory Config() => _instance;

  Config._internal() {
    final configString = configFile.readAsStringSync();
    config = loadYaml(configString) as Map;
  }

  String get dataDirectory => config["dataDirectory"];
  int get serverPort => config["serverPort"] ?? 8080;
}
