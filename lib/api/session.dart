// Import necessary packages and files
import "dart:convert";

import "package:http/http.dart" as http;
import "package:patinka/api/config/config.dart";
import "package:patinka/api/response_handler.dart";

// Define a class for handling Session API operations
class SessionAPI {
  // Define URLs for creating and retrieving sessions
  static final Uri _sessionUrl = Uri.parse("${Config.uri}/session/session");
  static final Uri _sessionsUrl = Uri.parse("${Config.uri}/session/sessions");

  // Method to create a new session
  static Future<Map<String, dynamic>> createSession(
    final String name,
    final String description,
    final List<String> images,
    final String type,
    final String share,
    final DateTime startTime,
    final DateTime endTime,
    final int distance,
    final double latitude,
    final double longitude,
  ) async {
    try {
      // Make a POST request to create a session
      final response = await http.post(
        _sessionUrl,
        headers: await Config.getDefaultHeadersAuth,
        body: {
          "name": name,
          "description": description,
          "images": jsonEncode(images),
          "type": type,
          "share": share,
          "start_time": startTime.toIso8601String(),
          "end_time": endTime.toIso8601String(),
          "distance": distance.toString(),
          "latitude": latitude.toString(),
          "longitude": longitude.toString()
        },
      );

      // Handle the response using a custom response handler
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // Throw an exception if an error occurs during the POST request
      throw Exception("Error during post: $e");
    }
  }

  // Method to get a list of sessions
  static Future<List<Map<String, dynamic>>> getSessions() async {
    try {
      // Make a GET request to retrieve sessions
      final response = await http.get(_sessionsUrl, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Bearer ${await storage.getToken()}",
      });

      // Handle the response using a custom response handler
      return handleResponse(response, Resp.listResponse);
    } catch (e) {
      // Throw an exception if an error occurs during the GET request
      throw Exception("Error during post: $e");
    }
  }
}
