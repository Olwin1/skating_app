import 'dart:convert';

import 'package:http/http.dart';
import 'package:patinka/api/type_casts.dart';

class ResponseHandler {
  static Map<String, dynamic> handleResponse(Response response) {
    if (response.statusCode == 200) {
      // Checking if the response status code is 200
      return TypeCasts.stringToJson(response.body);
    } else {
      // If the response status code is not 200
      throw Exception(
          "Request Unsuccessful: ${response.reasonPhrase}"); // Throwing an exception with an error message
    }
  }

  static List<Map<String, dynamic>> handleListResponse(Response response) {
    if (response.statusCode == 200) {
      // Checking if the response status code is 200
      return TypeCasts.stringArrayToJsonArray(response.body);
    } else {
      // If the response status code is not 200
      throw Exception(
          "Request Unsuccessful: ${response.reasonPhrase}"); // Throwing an exception with an error message
    }
  }

  static List<String> handleListStringResponse(Response response) {
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((element) => element.toString()).toList();

      // Decoding the response body and converting it into a List of Map objects
    } else {
      // If the HTTP response status code is not 200,
      // then an exception is thrown with the response reason phrase.
      throw Exception("Request Unsuccessful: ${response.reasonPhrase}");
    }
  }
}
