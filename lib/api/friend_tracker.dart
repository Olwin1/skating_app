// Import necessary packages
import "dart:convert"; // For JSON encoding and decoding

import "package:http/http.dart" as http; // HTTP client for making requests
import "package:patinka/api/config.dart"; // Configuration file for the application
import "package:patinka/api/response_handler.dart"; // Custom response handler
import "package:patinka/common_logger.dart"; // Custom logger for logging

// Class for handling API requests related to messages
class MessagesAPI {
  // Define the base URL for the search API
  static final Uri _searchUrl = Uri.parse("${Config.uri}/location/search");

  // Function to perform a search with given terms
  static Future<Map<String, dynamic>> search(
      final Map<String, String> terms) async {
    try {
      // Initialize an empty map to hold the processed search terms
      final Map<String, String> searchTerms = {};

      // Process each term in the input map
      for (final String term in terms.keys) {
        if (terms[term] != null) {
          // Remove colons and quotes from the search term and its value
          searchTerms[term.replaceFirst(":", "")] = terms[term]!
              .replaceFirst(term, "")
              .replaceFirst('"', "")
              .replaceFirst('"', "");
        }
      }

      // Make a GET request to the search API
      final response = await http.post(_searchUrl, headers: {
        "Content-Type": "application/x-www-form-urlencoded", // Set content type
        "Authorization":
            "Bearer ${await storage.getToken()}", // Add authorization token
      }, body: {
        "terms": jsonEncode(
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
