import "dart:convert";

import "package:http/http.dart" as http;
import "package:http/http.dart";
import "package:patinka/api/type_casts.dart";

enum Resp { stringResponse, listResponse, listStringResponse }

class ResponseHandler {
  static Map<String, dynamic> handleResponse(final Response response) => TypeCasts.stringToJson(response.body);

  static List<Map<String, dynamic>> handleListResponse(final Response response) => TypeCasts.stringArrayToJsonArray(response.body);

  static List<String> handleListStringResponse(final Response response) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((final element) => element.toString()).toList();
  }
}

// Function to handle HTTP request errors
void _handleError(final dynamic error) {
  throw Exception("Error during request: $error");
}

// Function to handle successful HTTP responses
dynamic handleResponse(final http.Response response, final Resp resp) {
  if (response.statusCode >= 200 && response.statusCode < 300) {
    switch (resp) {
      case Resp.stringResponse:
        {
          return ResponseHandler.handleResponse(response);
        }
      case Resp.listResponse:
        {
          return ResponseHandler.handleListResponse(response);
        }
      case Resp.listStringResponse:
        {
          return ResponseHandler.handleListStringResponse(response);
        }
    }
  } else {
    _handleError("Received status code ${response.statusCode}");
  }
}
