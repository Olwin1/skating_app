// Import necessary dependencies and files
import "package:http/http.dart" as http;
import "package:patinka/api/config.dart";
import "package:patinka/api/response_handler.dart";
import "package:patinka/common_logger.dart";

// Define a function to authenticate user credentials and return a token
Future<Map<String, dynamic>?> updateToken(final String fcmToken) async {
  // Define the URL endpoint for login
  final url = Uri.parse("${Config.uri}/notifications/token");

  try {
    commonLogger.d("Stored user auth token is: ${await storage.getToken()}");
    // Make a POST request to the login endpoint with the user's credentials
    final response = await http.post(
      url,
      headers: await Config.getDefaultHeadersAuth,
      body: {"fcm_token": fcmToken},
    );
    if (response.statusCode != 200) {
      return null;
    }

    return ResponseHandler.handleResponse(response);
  } catch (e) {
    // If there is an error during login, throw an exception with the error message
    throw Exception("Error during login: $e");
  }
}
