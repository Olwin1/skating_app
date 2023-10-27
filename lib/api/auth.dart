// Import necessary dependencies and files
import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:convert';

// Export login and signup functions from auth.dart
export 'package:patinka/api/auth.dart';

// Define a function to authenticate user credentials and return a token
Future<String> login(String username, String password) async {
  // Define the URL endpoint for login
  var url = Uri.parse('${Config.uri}/user/login');

  try {
    // Make a POST request to the login endpoint with the user's credentials
    var response = await http.post(
      url,
      headers: Config.defaultHeaders,
      body: {'username': username, 'password': password},
    );

    // If the response is successful, extract the token from the response body and return it
    if (response.statusCode == 200) {
      Map<String, dynamic> y = json.decode(response.body);
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
Future<String> signup(String username, String password, String email) async {
  // Define the URL endpoint for signup
  var url = Uri.parse('${Config.uri}/user/signup');

  // Make a POST request to the signup endpoint with the user's credentials
  var response = await http.post(
    url,
    headers: Config.defaultHeaders,
    body: {'username': username, 'password': password, 'email': email},
  );

  // If the response is successful, return the response body
  if (response.statusCode == 201) {
    return response.body;
  } else {
    // If the response is not successful, throw an exception with the reason phrase
    throw (Exception("Signup Unsuccessful: ${response.reasonPhrase}"));
  }
}
