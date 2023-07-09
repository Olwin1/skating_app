import 'dart:io' show Platform;

class Config {
  static String uri =
      Platform.isAndroid ? 'http://10.0.2.2:4000' : 'http://localhost:4000';
}
