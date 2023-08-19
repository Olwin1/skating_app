import 'dart:convert';

import 'package:http/http.dart';
import 'package:patinka/api/type_casts.dart';
import 'package:http/http.dart' as http;

enum Resp { stringResponse, listResponse, listStringResponse }

class ResponseHandler {
  static Map<String, dynamic> handleResponse(Response response) {
    return TypeCasts.stringToJson(response.body);
  }

  static List<Map<String, dynamic>> handleListResponse(Response response) {
    return TypeCasts.stringArrayToJsonArray(response.body);
  }

  static List<String> handleListStringResponse(Response response) {
    List<dynamic> data = json.decode(response.body);
    return data.map((element) => element.toString()).toList();
  }
}

// Function to handle HTTP request errors
void _handleError(dynamic error) {
  throw Exception("Error during request: $error");
}

// Function to handle successful HTTP responses
dynamic handleResponse(http.Response response, Resp resp) {
  if (response.statusCode == 200) {
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
