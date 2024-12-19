// Import the FlutterSecureStorage package
import "dart:convert";

import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:patinka/caching/manager.dart";
import "package:patinka/common_logger.dart";

// Create a class named SecureStorage
class SecureStorage {
  // Create an instance of FlutterSecureStorage
  final storage = const FlutterSecureStorage();

  // Define a private constant variable _keyToken with value "token"
  static const _keyToken = "token";
  static const _keyId = "id";
  static const _keyMuted = "muted_value";

  // Define a method named setToken that accepts a String parameter named token and returns a Future
  Future setToken(final String token) async {
    commonLogger.d("Setting the token at $_keyToken to $token");
    // Use the FlutterSecureStorage instance to write the token to storage with the _keyToken key
    await storage.write(key: _keyToken, value: token);
  }

  // Define a method named getToken that returns a Future<String>
  Future<String?> getToken() async => await storage.read(key: _keyToken);

  // Define a method named setToken that accepts a String parameter named token and returns a Future
  Future setId(final String id) async {
    // Use the FlutterSecureStorage instance to write the token to storage with the _keyToken key
    await storage.write(key: _keyId, value: id);
  }

  // Define a method named getToken that returns a Future<String>
  Future<String?> getId() async => await storage.read(key: _keyId);

  Future logout() async {
    commonLogger.d("Deleting local storage");
    // Use the FlutterSecureStorage instance to write the token to storage with the _keyToken key
    await storage.deleteAll();
    NetworkManager.instance.deleteAllLocalData();
  }

  // Define a method named setMuted that sets the data for muted on app start
  Future setMuted(final bool muted, final String? endTimestamp) async {
    commonLogger.d("Setting the muted value to $muted");

    final String jsonMutedData =
        jsonEncode({"isMuted": muted, "endTimestamp": endTimestamp});

    // Use the FlutterSecureStorage instance to write the muted value
    await storage.write(key: _keyMuted, value: jsonMutedData);
  }

  Future<Map<String, dynamic>?> getMuted() async =>
      jsonDecode((await storage.read(key: _keyMuted)) ??
          "{'isMuted': false, 'endTimestamp': null}");
}
