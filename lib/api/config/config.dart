import "package:flutter/foundation.dart" show kDebugMode;
import "package:flutter/material.dart";
import "package:patinka/api/config/platform_config_stub.dart"
    if (dart.library.io) "package:patinka/api/config/platform_config_io.dart";
import "package:patinka/api/token.dart";

SecureStorage storage = SecureStorage();

enum CacheTypes { user, post, messages, list, misc, verified, background }

class Config {
  static String uri = kDebugMode ? getBaseUri() : "https://patinka.xyz:4000";

  static Map<String, String>? defaultHeaders = {
    "Content-Type": "application/x-www-form-urlencoded"
  };

  static Future<Map<String, String>?> get getDefaultHeadersAuth async => {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Bearer ${await storage.getToken()}",
      };

  static Color appbarColour = const Color(0x66000000);
}
