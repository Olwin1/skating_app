import 'package:patinka/api/response_handler.dart';

import 'package:http/http.dart'
    as http; // Importing the 'http' package from the 'http' file
import 'config.dart'; // Importing the 'config.dart' file
import 'dart:convert'; // Importing the 'dart:convert' package

class SessionAPI {
  static final Uri _sessionUrl = Uri.parse('${Config.uri}/session/session');
  static final Uri _sessionsUrl = Uri.parse('${Config.uri}/session/sessions');

  static Future<Map<String, dynamic>> createSession(
    // Creating a function 'createSession' with the specified parameters
    String name,
    String description,
    List<String> images,
    String type,
    String share,
    DateTime startTime,
    DateTime endTime,
    int distance,
    double latitude,
    double longitude,
  ) async {
    // Specifying that the function returns a future object of a Map object with key-value pairs of type string-dynamic

    try {
      // Using a try-catch block to handle errors
      var response = await http.post(
        // Creating a variable 'response' and making a post request to the specified URL
        _sessionUrl,
        headers: await Config.getDefaultHeadersAuth,
        body: {
          // Specifying the body of the request
          'name': name,
          'description': description,
          'images': jsonEncode(images),
          'type': type,
          'share': share,
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'distance': distance.toString(),
          'latitude': latitude.toString(),
          'longitude': longitude.toString()
        },
      );

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // Handling the error
      throw Exception(
          "Error during post: $e"); // Throwing an exception with an error message
    }
  }

// This function returns a Future object that contains a List of Maps with String keys and dynamic values, representing session data.

  static Future<List<Map<String, dynamic>>> getSessions() async {
    // Define the URL endpoint to request the session data from.

    try {
      // Send an HTTP GET request to the defined URL and include headers for Content-Type and Authorization.
      var response = await http.get(_sessionsUrl, headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}',
      });

      return handleResponse(response, Resp.listResponse);
      // If an exception occurs during the request, throw a more descriptive Exception object containing the error message.
    } catch (e) {
      throw Exception("Error during post: $e");
    }
  }
}
