// Import necessary libraries and files
import 'package:patinka/api/response_handler.dart';
import 'package:patinka/common_logger.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:convert';

// Define a class for handling API requests related to messages
class MessagesAPI {
  // Define URIs for different API endpoints
  static final Uri _searchUrl = Uri.parse('${Config.uri}/location/search');

  // Define a static method to check if the user is friends with another user
  static Future<Map<String, dynamic>> search(Map<String, String> terms) async {
    try {
      Map<String, String> searchTerms = {};
      for (String term in terms.keys) {
        if (terms[term] != null) {
          searchTerms[term.replaceFirst(":", "")] = terms[term]!
              .replaceFirst(term, "")
              .replaceFirst('"', '')
              .replaceFirst('"', '');
        }
      }
      // Send a GET request to the friend check URL with user information
      var response = await http.get(_searchUrl, headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}',
        'terms': jsonEncode(searchTerms)
      });

      // Check the response status code
      if (response.statusCode == 200) {
        commonLogger.t("Response: 200 Search Successful");

        // Parse the response body and return the result
        return handleResponse(response, Resp.stringResponse);
      }
      throw Exception("Search Unsuccessful: ${response.reasonPhrase}");
    } catch (e) {
      // Throw an exception if there's an error during the friend check process
      throw Exception("Error during search: $e");
    }
  }
}
