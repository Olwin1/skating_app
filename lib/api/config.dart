import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'token.dart';

SecureStorage storage = SecureStorage();

enum CacheTypes { user, post, messages, list, misc, verified }

class Config {
  // static String uri =
  //     Platform.isAndroid ? 'http://10.0.2.2:4000' : 'http://localhost:4000';
  static String uri = kDebugMode
      ? Platform.isAndroid
          ? 'http://10.0.2.2:4000'
          : 'http://localhost:4000'
      : "https://sabreguild.com:4000";
  static Map<String, String>? defaultHeaders = {
    'Content-Type': 'application/x-www-form-urlencoded'
  };
  static Future<Map<String, String>?> get getDefaultHeadersAuth async => {
        // Set the request headers
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}',
      };
  static Color appbarColour = const Color(0x66000000);
}
