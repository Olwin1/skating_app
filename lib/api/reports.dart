// Import necessary libraries and modules
import "package:http/http.dart" as http;
import "package:patinka/api/config/config.dart";
import "package:patinka/api/response_handler.dart";
import "package:patinka/social_media/report_content_type.dart";

// The ReportAPI class provides methods to handle various report-related actions, such as reporting users,
// modifying report statuses, and fetching reports. It interacts with an API backend using HTTP requests.
class ReportAPI {
  // Define API endpoints for different report actions
  static final Uri _reportUrl = Uri.parse("${Config.uri}/support/report");
  static final Uri _reportDataUrl =
      Uri.parse("${Config.uri}/support/report_data");
  static final Uri _reportModifyUrl = Uri.parse("$_reportUrl/modify");
  static final Uri _reportMessageUrl = Uri.parse("$_reportUrl/message");
  static final Uri _reportMessagesUrl = Uri.parse("${_reportMessagesUrl}s");
  static final Uri _reportListUrl = Uri.parse("$_reportUrl/list");
  static final Uri _reportListFromUrl = Uri.parse("$_reportListUrl/from");
  static final Uri _reportListAgainstUrl = Uri.parse("$_reportListUrl/against");

  // Submits a new report to the server
  // Parameters:
  // - reportContentType: Type of content being reported (e.g., message, post, etc.)
  // - contentId: ID of the content being reported
  // - reportedUserId: ID of the user being reported
  // - reportType: Type of the report (e.g., spam, harassment, etc.)
  // Returns: A map containing the server's response
  static Future<Map<String, dynamic>> postReport(
      final ReportContentType reportContentType,
      final String contentId,
      final String reportedUserId,
      final String reportType) async {
    try {
      final response = await http.post(
        _reportUrl,
        headers: await Config.getDefaultHeadersAuth,
        body: {
          "reported_content": reportContentType.name,
          "reported_content_id": contentId,
          "reported_user_id": reportedUserId,
          "report_type": reportType,
          "description": "" // Optional description of the report
        },
      );

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // Handle any errors during the report creation process
      throw Exception("Error during report creation: $e");
    }
  }

  // Fetches a single report by its unique ID
  // Parameters:
  // - reportId: ID of the report to retrieve
  // Returns: A map containing the details of the report
  static Future<Map<String, dynamic>> getReport(final String reportId) async {
    try {
      final response = await http.get(
        _reportUrl,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Bearer ${await storage.getToken()}",
          "report_id": reportId
        },
      );

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // Handle any errors during the report retrieval process
      throw Exception("Error while getting report: $e");
    }
  }

  // Fetches detailed content data of a specific report by its ID
  // Parameters:
  // - reportId: ID of the report to retrieve
  // - type: Type of content being reported (e.g., message, post, etc.)
  // Returns: A map containing the content data of the report
  static Future<dynamic> getReportData(
      final String reportId, final ReportContentType type) async {
    try {
      final response = await http.get(
        _reportDataUrl,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Bearer ${await storage.getToken()}",
          "report_id": reportId
        },
      );

      // Handle different content types (e.g., list response for messages)
      if (type == ReportContentType.message) {
        return handleResponse(response, Resp.listResponse);
      }
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // Handle any errors during the report content data retrieval process
      throw Exception("Error while getting report content data: $e");
    }
  }

  // Modifies the status of a specific report
  // Parameters:
  // - reportId: ID of the report to modify
  // - reportStatus: New status for the report (e.g., resolved, dismissed)
  // Returns: A map containing the updated report information
  static Future<Map<String, dynamic>> modifyReportStatus(
      final String reportId, final String reportStatus) async {
    try {
      final response = await http.post(
        _reportModifyUrl,
        headers: await Config.getDefaultHeadersAuth,
        body: {"report_id": reportId, "report_status": reportStatus},
      );

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // Handle any errors during the report status update process
      throw Exception("Error during report status update: $e");
    }
  }

  // Fetches a paginated list of reports
  // Parameters:
  // - page: Page number for pagination
  // Returns: A map containing a list of reports
  static Future<List<Map<String, dynamic>>> getReports(
      final int page, final bool isSelf) async {
    try {
      final response = await http.get(
        _reportListUrl,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Bearer ${await storage.getToken()}",
          "page": page.toString(),
          "is_self": isSelf.toString()
        },
      );

      return handleResponse(response, Resp.listResponse);
    } catch (e) {
      // Handle any errors during the reports retrieval process
      throw Exception("Error while getting reports: $e");
    }
  }

  // Fetches a paginated list of reports submitted by a specific user (defaults to the authenticated user)
  // Parameters:
  // - page: Page number for pagination
  // - userId: Optional user ID to filter reports (if null, defaults to the requesting user)
  // Returns: A map containing a list of reports
  static Future<List<Map<String, dynamic>>> getReportsFrom(
      final int page, final String? userId) async {
    try {
      final response = await http.get(
        _reportListFromUrl,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Bearer ${await storage.getToken()}",
          "page": page.toString(),
          "user":
              userId ?? "" // Default to current user if no userId is provided
        },
      );

      return handleResponse(response, Resp.listResponse);
    } catch (e) {
      // Handle any errors during the reports retrieval process
      throw Exception("Error while getting reports: $e");
    }
  }

  // Fetches a paginated list of reports filed against a specific user
  // Parameters:
  // - page: Page number for pagination
  // - userId: ID of the user the reports are filed against
  // Returns: A map containing a list of reports
  static Future<List<Map<String, dynamic>>> getReportsAgainst(
      final int page, final String userId) async {
    try {
      final response = await http.get(
        _reportListAgainstUrl,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Bearer ${await storage.getToken()}",
          "page": page.toString(),
          "user": userId
        },
      );

      return handleResponse(response, Resp.listResponse);
    } catch (e) {
      // Handle any errors during the reports retrieval process
      throw Exception("Error while getting reports: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> getReportMessages(
      final int page, final String reportId) async {
    try {
      final response = await http.get(
        _reportMessagesUrl,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Bearer ${await storage.getToken()}",
          "page": page.toString(),
          "report_id": reportId
        },
      );

      return handleResponse(response, Resp.listResponse);
    } catch (e) {
      // Handle any errors during the reports retrieval process
      throw Exception("Error while getting reports: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> postReportMessage(
      final String reportId, final String message) async {
    try {
      final response = await http.post(_reportMessageUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {"report_id": reportId, "content": message});

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // Handle any errors during the reports retrieval process
      throw Exception("Error while posting report message: $e");
    }
  }
}
