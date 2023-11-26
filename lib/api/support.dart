// Import necessary libraries and modules
import 'package:patinka/api/response_handler.dart';
import 'package:patinka/caching/manager.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

// Define a class called SupportAPI' for handling various support-related actions
class SupportAPI {
  // Define static URIs for different support actions
  static final Uri _supportUrl = Uri.parse('${Config.uri}/support/support');
  static final Uri _bugUrl = Uri.parse('${Config.uri}/support/bug');
  static final Uri _feedbackUrl = Uri.parse('${Config.uri}/support/feedback');

  // Define a static method to submit a support request
  static Future<Map<String, dynamic>> submitSupportRequest(
      String subject, String content) async {
    try {
      // Call the generic submit method with support-specific parameters
      return await _submit(_supportUrl, subject, content, "support-requests");
    } catch (e) {
      // Throw an exception if there's an error during the support request process
      throw Exception("Error during support request: $e");
    }
  }

  // Define a static method to submit a feature request
  static Future<Map<String, dynamic>> submitFeatureRequest(
      String subject, String content) async {
    try {
      // Call the generic submit method with feature-specific parameters
      return await _submit(_feedbackUrl, subject, content, "feature-requests");
    } catch (e) {
      // Throw an exception if there's an error during the feature request process
      throw Exception("Error during feature request: $e");
    }
  }

  // Define a static method to submit a bug report
  static Future<Map<String, dynamic>> submitBugReport(
      String subject, String content) async {
    try {
      // Call the generic submit method with bug-specific parameters
      return await _submit(_bugUrl, subject, content, "bug-reports");
    } catch (e) {
      // Throw an exception if there's an error during the bug report process
      throw Exception("Error during bug report: $e");
    }
  }

  // Define a static method to get a list of bug reports
  static Future<List<Map<String, dynamic>>> getBugReports(int page) async {
    try {
      // Call the generic get method with bug-specific parameters
      return await _get(_bugUrl, "bug-reports", page);
    } catch (e) {
      // Throw an exception if there's an error during the bug report retrieval process
      throw Exception("Error during bug report retrieval: $e");
    }
  }

  // Define a static method to get a list of support requests
  static Future<List<Map<String, dynamic>>> getSupportRequests(int page) async {
    try {
      // Call the generic get method with support-specific parameters
      return await _get(_supportUrl, "support-requests", page);
    } catch (e) {
      // Throw an exception if there's an error during the support request retrieval process
      throw Exception("Error during support request retrieval: $e");
    }
  }

  // Define a static method to get a list of feature requests
  static Future<List<Map<String, dynamic>>> getFeatureRequests(int page) async {
    try {
      // Call the generic get method with feature-specific parameters
      return await _get(_feedbackUrl, "feature-requests", page);
    } catch (e) {
      // Throw an exception if there's an error during the feature request retrieval process
      throw Exception("Error during feature requests retrieval: $e");
    }
  }

  // Define a generic submit method to handle common functionality for different requests
  static dynamic _submit(
      Uri url, String subject, String content, String type) async {
    // Send a POST request to the specified URL with user information
    var response = await http
        .post(url, headers: await Config.getDefaultHeadersAuth, body: {
      'subject': subject,
      'content': content,
    });

    // Delete local cached data related to the submitted type
    NetworkManager.instance.deleteLocalData(name: type, type: CacheTypes.list);

    // Handle and return the response using the appropriate response handler
    return handleResponse(response, Resp.stringResponse);
  }

  // Define a generic get method to handle common functionality for different requests
  static Future<List<Map<String, dynamic>>> _get(
      Uri url, String type, int page) async {
    // Send GET request to retrieve user suggestions
    var response = await http.get(url, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer ${await storage.getToken()}',
      'page': page.toString(),
    });

    // Handle the response using a custom response handler and return the result
    return handleResponse(response, Resp.listResponse);
  }
}
