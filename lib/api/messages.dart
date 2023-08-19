// Importing the required dependencies
import 'package:patinka/api/response_handler.dart';
import 'package:patinka/api/type_casts.dart';

import '../caching/manager.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:convert';

class MessagesAPI {
  static final Uri _channelUrl = Uri.parse('${Config.uri}/message/channel');
  static final Uri _messageUrl = Uri.parse('${Config.uri}/message/message');
  static final Uri _messagesUrl = Uri.parse('${Config.uri}/message/messages');
  static final Uri _channelsUrl = Uri.parse('${Config.uri}/message/channels');
  static final Uri _suggestionsUrl = Uri.parse('${Config.uri}/message/users');

// Function to create a new channel
  static Future<Map<String, dynamic>> postChannel(
      List<String> participants) async {
    try {
      NetworkManager.instance
          .deleteLocalData(name: "channels", type: CacheTypes.list);
      // Making a POST request to the specified URL with the required headers and body
      var response = await http.post(
        _channelUrl,
        headers: await Config.getDefaultHeadersAuth,
        body: {'participants': jsonEncode(participants)},
      );

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // If there is any error, throw an exception with the error message
      throw Exception("Error during post: $e");
    }
  }

  static Future<String?> getUserId() async {
    return await storage.getId();
  }

// Function to send a message to a channel
  static Future<Object> postMessage(String channel, String content, String? img,
      List<dynamic>? fcmToken) async {
    try {
      // Making a POST request to the specified URL with the required headers and body
      var response = await http.post(
        _messageUrl,
        headers: await Config.getDefaultHeadersAuth,
        body: {
          'channel': channel,
          'content': content,
          if (img != null) 'img': img,
          "fcm_token": jsonEncode(fcmToken)
        },
      );

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // If there is any error, throw an exception with the error message
      throw Exception("Error during post: $e");
    }
  }

  static Future<Object> getMessage(
      String message, String messageNumber, String channel) async {
    // Make an HTTP GET request to the specified URL with headers and parameters
    try {
      var response = await http.get(_messageUrl, headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}',
        'message': message,
        'message_number': messageNumber,
        'channel': channel,
      });

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // If an error occurs during the HTTP request, throw an exception with the error message
      throw Exception("Error during post: $e");
    }
  }

// This is a function that takes in two arguments, `page` and `channel`,
// and returns a Future that resolves to a Map of String to dynamic values.

  static Future<List<Object>> getMessages(int page, String channel) async {
    // `url` is a Uri object that is constructed with a string
    // that includes the base URI and the endpoint path.

    try {
      // `response` is an HTTP response that is returned from an asynchronous
      // HTTP GET request that is made using the `http` package.
      // It includes headers and body.
      var response = await http.get(_messagesUrl, headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}',
        'page': page.toString(),
        'channel': channel,
      });

      // If the HTTP response status code is 200,
      // then the response body is decoded from JSON
      // and returned as a Map of String to dynamic values.
      return handleResponse(response, Resp.listResponse);
    } catch (e) {
      // If an error occurs during the HTTP GET request,
      // then an exception is thrown with the error message.
      throw Exception("Error during post: $e");
    }
  }

// This function doth take a single argument, a string called 'page'
// It returns a Future object, the value of which shall be determined in due course
  static Future<List<Map<String, dynamic>>> getChannels(int page) async {
    // Declare a new variable called 'url' and assign it a new Uri object which contains the base URL of the API endpoint

    try {
      if (page == 0) {
        String? localData = await NetworkManager.instance
            .getLocalData(name: "channels", type: CacheTypes.list);

        if (localData != null) {
          List<Map<String, dynamic>> cachedChannels =
              TypeCasts.stringArrayToJsonArray(localData);
          return cachedChannels;
        }
      }
      // Issue an HTTP GET request to the aforementioned URL, with some headers added for good measure
      var response = await http.get(_channelsUrl, headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}',
        'page': page.toString(),
      });
      List<Map<String, dynamic>> data =
          handleResponse(response, Resp.listResponse);
      if (page == 0) {
        NetworkManager.instance
            .saveData(name: "channels", type: CacheTypes.list, data: data);
      }

      // If the response status code is 200, then decode the response body into a new map object called 'y' and return it
      return data;
    } catch (e) {
      // If an error is thrown within the try-catch block, then throw a different Exception which contains a message that describes the error that was encountered
      throw Exception("Error during post: $e");
    }
  }

  static Future<Object> getChannel(String channel) async {
    // Construct URL for the API endpoint

    try {
      // Send a GET request to the API endpoint with the channel parameter
      var response = await http.get(_channelUrl, headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}',
        'channel': channel,
      });

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // Catch any errors that occur during the API call and throw an exception
      throw Exception("Error during API call: $e");
    }
  }

  static Future<List<String>> getSuggestions(int page) async {
    // `url` is a Uri object that is constructed with a string
    // that includes the base URI and the endpoint path.

    try {
      // `response` is an HTTP response that is returned from an asynchronous
      // HTTP GET request that is made using the `http` package.
      // It includes headers and body.
      var response = await http.get(_suggestionsUrl, headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}',
        'page': page.toString(),
      });

      // If the HTTP response status code is 200,
      // then the response body is decoded from JSON
      // and returned as a Map of String to dynamic values.
      return handleResponse(response, Resp.listStringResponse);
    } catch (e) {
      // If an error occurs during the HTTP GET request,
      // then an exception is thrown with the error message.
      throw Exception("Error during post: $e");
    }
  }
}
