import 'dart:convert';

class TypeCasts {
  static Map<String, dynamic> stringToJson(String str) {
    Map<String, dynamic> a = json.decode(str);
    return a;
  }

  static List<Map<String, dynamic>> stringArrayToJsonArray(String str) {
    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      json.decode(str).map((model) => Map<String, dynamic>.from(model)),
    ); // Decoding the response body and converting it into a List of Map objects
    return data; // Returning the Map object
  }
}
