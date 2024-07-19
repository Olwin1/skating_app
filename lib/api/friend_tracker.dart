// Import necessary packages
import 'package:patinka/api/response_handler.dart'; // Custom response handler
import 'package:patinka/common_logger.dart'; // Custom logger for logging
import 'package:http/http.dart' as http; // HTTP client for making requests
import 'config.dart'; // Configuration file for the application
import 'dart:convert'; // For JSON encoding and decoding

// Class for handling API requests related to messages
class MessagesAPI {
  // Define the base URL for the search API
  static final Uri _searchUrl = Uri.parse('${Config.uri}/location/search');

  // Function to perform a search with given terms
  static Future<Map<String, dynamic>> search(Map<String, String> terms) async {
    try {
      // Initialize an empty map to hold the processed search terms
      Map<String, String> searchTerms = {};

      // Process each term in the input map
      for (String term in terms.keys) {
        if (terms[term] != null) {
          // Remove colons and quotes from the search term and its value
          searchTerms[term.replaceFirst(":", "")] = terms[term]!
              .replaceFirst(term, "")
              .replaceFirst('"', '')
              .replaceFirst('"', '');
        }
      }

      // Make a GET request to the search API
      var response = await http.get(_searchUrl, headers: {
        'Content-Type': 'application/x-www-form-urlencoded', // Set content type
        'Authorization':
            'Bearer ${await storage.getToken()}', // Add authorization token
        'terms': jsonEncode(
            searchTerms) // Add the search terms as a JSON-encoded string
      });

      // Check if the response status is OK (200)
      if (response.statusCode == 200) {
        commonLogger
            .t("Response: 200 Search Successful"); // Log success message
        return handleResponse(
            response, Resp.stringResponse); // Handle and return the response
      }

      // Throw an exception if the search was unsuccessful
      throw Exception("Search Unsuccessful: ${response.reasonPhrase}");
    } catch (e) {
      // Catch and throw any errors that occur during the search process
      throw Exception("Error during search: $e");
    }
  }
}
