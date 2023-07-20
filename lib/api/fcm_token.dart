// Import necessary dependencies and files
import '../common_logger.dart';
import 'token.dart';

import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:convert';

SecureStorage storage = SecureStorage();

// Define a function to authenticate user credentials and return a token
Future<Map<String, dynamic>?> updateToken(String fcmToken) async {
  // Define the URL endpoint for login
  var url = Uri.parse('${Config.uri}/notifications/token');

  try {
    commonLogger.d("Stored user auth token is: ${await storage.getToken()}");
    // Make a POST request to the login endpoint with the user's credentials
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}',
      },
      body: {'fcm_token': fcmToken},
    );

    // If the response is successful, extract the token from the response body and return it
    if (response.statusCode == 200) {
      Map<String, dynamic> y = json.decode(response.body);
      return y;
    } else {
      // If the response is not successful, throw an exception with the reason phrase
      throw Exception("Login Unsuccessful: ${response.reasonPhrase}");
    }
  } catch (e) {
    // If there is an error during login, throw an exception with the error message
    throw Exception("Error during login: $e");
  }
}
