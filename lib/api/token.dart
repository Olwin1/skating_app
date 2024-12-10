// Import the FlutterSecureStorage package
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
}
