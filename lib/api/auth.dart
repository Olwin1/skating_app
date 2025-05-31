// Import necessary dependencies and files
import "dart:convert";

import "package:http/http.dart" as http;
import "package:patinka/api/config.dart";
import "package:patinka/api/response_handler.dart";
import "package:patinka/caching/manager.dart";

class AuthenticationAPI {
// Define a function to authenticate user credentials and return a token
  static Future<String> login(
      final String username, final String password) async {
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
        NetworkManager.instance.saveData(
            name: "user-id", type: CacheTypes.misc, data: y["user_id"]);
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
  static Future<String> signup(
      final String username, final String password, final String email) async {
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

  static Future<Map<String, dynamic>> isRestricted() async {
    final url = Uri.parse("${Config.uri}/user/is_restricted");

    try {
      final response = await http.get(
        url,
        headers: await Config.getDefaultHeadersAuth,
      );

      if (response.statusCode == 200) {
        return handleResponse(response, Resp.stringResponse);
      } else {
        throw Exception(
            "Error during punishment check: ${response.reasonPhrase}");
      }
    } catch (e) {
      throw Exception("Error during punishment verification: $e");
    }
  }


// Method to only be used to update the cache of the user's own id
    static Future<String> _fetchUserId() async {
    final url = Uri.parse("${Config.uri}/user/id");

    try {
      final response = await http.get(
        url,
        headers: await Config.getDefaultHeadersAuth,
      );

      if (response.statusCode == 200) {
        return handleResponse(response, Resp.stringResponse)["user_id"];
      } else {
        throw Exception(
            "Error during id fetch: ${response.reasonPhrase}");
      }
    } catch (e) {
      throw Exception("Error during id fetch: $e");
    }
  }
  /// Simple method to get the logged in userid
  /// This only gets the cached id and should not be relied on.
  /// Only use this for GUI changes and such.
  /// Only send to server if it does its own checks
  static Future<String> getUserId() async {
    // Attempt to load user id from cache
    final String? userIdCache = await NetworkManager.instance.getLocalData(
            name: "user-id", type: CacheTypes.misc);

            // If it cannot be found in cache then ask for it from the server
            if(userIdCache == null) {
              final String fetchedUserId = await _fetchUserId();
              // Save the data to the cache for future reference
               NetworkManager.instance.saveData(
            name: "user-id", type: CacheTypes.misc, data: fetchedUserId);
            // Return the id back to the caller
            return fetchedUserId;

            }
            // Return the id back to the caller while removing unused quotations
            return userIdCache.replaceAll('"', "");
            }
}
