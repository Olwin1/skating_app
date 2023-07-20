import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

class Config {
  // static String uri =
  //     Platform.isAndroid ? 'http://10.0.2.2:4000' : 'http://localhost:4000';
  static String uri = kDebugMode
      ? Platform.isAndroid
          ? 'http://10.0.2.2:4000'
          : 'http://localhost:4000'
      : "https://sabreguild.com:4000";
}
