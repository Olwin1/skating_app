// Import necessary libraries and modules
import "package:http/http.dart" as http;
import "package:patinka/api/config.dart";
import "package:patinka/api/response_handler.dart";
import "package:patinka/caching/manager.dart";

// Define a class called SupportAPI' for handling various support-related actions
class SupportAPI {
  // Define static URIs for different support actions
  static final Uri _supportUrl = Uri.parse("${Config.uri}/support/support");
  static final Uri _bugUrl = Uri.parse("${Config.uri}/support/bug");
  static final Uri _feedbackUrl = Uri.parse("${Config.uri}/support/feedback");
  static final Uri _messagesUrl = Uri.parse("${Config.uri}/support/messages");
  static final Uri _messageUrl = Uri.parse("${Config.uri}/support/message");
  static final Uri _blockUrl = Uri.parse("${Config.uri}/user/block");
  static final Uri _unblockUrl = Uri.parse("${Config.uri}/user/unblock");

  // Define a static method to submit a support request
  static Future<Map<String, dynamic>> submitSupportRequest(
      final String subject, final String content) async {
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
      final String subject, final String content) async {
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
      final String subject, final String content) async {
    try {
      // Call the generic submit method with bug-specific parameters
      return await _submit(_bugUrl, subject, content, "bug-reports");
    } catch (e) {
      // Throw an exception if there's an error during the bug report process
      throw Exception("Error during bug report: $e");
    }
  }

  // Define a static method to get a list of bug reports
  static Future<List<Map<String, dynamic>>> getBugReports(final int page) async {
    try {
      // Call the generic get method with bug-specific parameters
      return await _get(_bugUrl, "bug-reports", page);
    } catch (e) {
      // Throw an exception if there's an error during the bug report retrieval process
      throw Exception("Error during bug report retrieval: $e");
    }
  }

  // Define a static method to get a list of support requests
  static Future<List<Map<String, dynamic>>> getSupportRequests(final int page) async {
    try {
      // Call the generic get method with support-specific parameters
      return await _get(_supportUrl, "support-requests", page);
    } catch (e) {
      // Throw an exception if there's an error during the support request retrieval process
      throw Exception("Error during support request retrieval: $e");
    }
  }

  // Define a static method to get a list of feature requests
  static Future<List<Map<String, dynamic>>> getFeatureRequests(final int page) async {
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
      final Uri url, final String subject, final String content, final String type) async {
    // Send a POST request to the specified URL with user information
    final response = await http
        .post(url, headers: await Config.getDefaultHeadersAuth, body: {
      "subject": subject,
      "content": content,
    });

    // Delete local cached data related to the submitted type
    NetworkManager.instance.deleteLocalData(name: type, type: CacheTypes.list);

    // Handle and return the response using the appropriate response handler
    return handleResponse(response, Resp.stringResponse);
  }

  // Define a generic get method to handle common functionality for different requests
  static Future<List<Map<String, dynamic>>> _get(
      final Uri url, final String type, final int page) async {
    // Send GET request to retrieve user suggestions
    final response = await http.get(url, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Bearer ${await storage.getToken()}",
      "page": page.toString(),
    });

    // Handle the response using a custom response handler and return the result
    return handleResponse(response, Resp.listResponse);
  }

  /// Retrieves a list of messages associated with a specific feedback ID and page.
  ///
  /// Parameters:
  /// - [feedbackId]: The unique identifier for the feedback.
  /// - [page]: The page number for paginated results.
  ///
  /// Returns:
  /// A [Future] that completes with a list of maps containing dynamic data.
  /// Each map represents a message with various attributes.
  ///
  /// Throws:
  /// An [Exception] if there is an error during the HTTP request.
  static Future<List<Map<String, dynamic>>> getMessages(
      final String feedbackId, final int page) async {
    try {
      final response = await http.get(
        _messagesUrl,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Bearer ${await storage.getToken()}",
          "feedback_id": feedbackId,
          "page": page.toString(),
        },
      );
      return handleResponse(response, Resp.listResponse);
    } catch (e) {
      throw Exception("Error during getMessages: $e");
    }
  }

  /// Posts a new message to a support request.
  ///
  /// Parameters:
  /// - [feedbackId]: The unique identifier for the feedback.
  /// - [content]: The content of the message to be posted.
  ///
  /// Returns:
  /// A [Future] that completes with a map containing dynamic data.
  /// The map represents the response received after posting the message.
  ///
  /// Throws:
  /// An [Exception] if there is an error during the HTTP request.
  static Future<Map<String, dynamic>> postMessage(
      final String feedbackId, final String content) async {
    try {
      final response = await http.post(_messageUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {"feedback_id": feedbackId, "content": content});

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      throw Exception("Error during postMessage: $e");
    }
  }




    static Future<Map<String, dynamic>> postBlockUser(
      final String targetUser) async {
    try {
      final response = await http.post(_blockUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {"user": targetUser});

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      throw Exception("Error during block: $e");
    }
  }

      static Future<Map<String, dynamic>> postUnblockUser(
      final String targetUser) async {
    try {
      final response = await http.post(_unblockUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {"user": targetUser});

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      throw Exception("Error during unblock: $e");
    }
  }
}
