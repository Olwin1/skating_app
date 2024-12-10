// Import necessary dependencies and files
import "dart:convert";

import "package:http/http.dart" as http;
import "package:patinka/api/config.dart";
import "package:patinka/caching/manager.dart";

// Export login and signup functions from auth.dart
export "package:patinka/api/auth.dart";

// Define a function to authenticate user credentials and return a token
Future<String> login(final String username, final String password) async {
  // Define the URL endpoint for login
  final url = Uri.parse("${Config.uri}/user/login");

  try {
    // Make a POST request to the login endpoint with the user's credentials
    final response = await http.post(
      url,
      headers: Config.defaultHeaders,
      body: {"username": username, "password": password},
    );

    // If the response is successful, extract the token from the response body and return it
    if (response.statusCode == 200) {
      final Map<String, dynamic> y = json.decode(response.body);
      NetworkManager.instance.saveData(
          name: "user-email-verified",
          type: CacheTypes.verified,
          data: y["verified"]);
      return y["token"];
    } else {
      // If the response is not successful, throw an exception with the reason phrase
      throw Exception("Login Unsuccessful: ${response.reasonPhrase}");
    }
  } catch (e) {
    // If there is an error during login, throw an exception with the error message
    throw Exception("Error during login: $e");
  }
}

// Define a function to create a new user account and return a response
Future<String> signup(final String username, final String password, final String email) async {
  // Define the URL endpoint for signup
  final url = Uri.parse("${Config.uri}/user/signup");

  // Make a POST request to the signup endpoint with the user's credentials
  final response = await http.post(
    url,
    headers: Config.defaultHeaders,
    body: {"username": username, "password": password, "email": email},
  );

  // If the response is successful, return the response body
  if (response.statusCode == 201) {
    return response.body;
  } else {
    // If the response is not successful, throw an exception with the reason phrase
    throw Exception("Signup Unsuccessful: ${response.reasonPhrase}");
  }
}
