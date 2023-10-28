// Import necessary libraries and files
import 'package:patinka/api/response_handler.dart';
import 'package:patinka/api/type_casts.dart';
import '../caching/manager.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:convert';

// Define a class for handling API requests related to messages
class MessagesAPI {
  // Define URIs for different API endpoints
  static final Uri _channelUrl = Uri.parse('${Config.uri}/message/channel');
  static final Uri _messageUrl = Uri.parse('${Config.uri}/message/message');
  static final Uri _messagesUrl = Uri.parse('${Config.uri}/message/messages');
  static final Uri _channelsUrl = Uri.parse('${Config.uri}/message/channels');
  static final Uri _suggestionsUrl = Uri.parse('${Config.uri}/message/users');

  // Method to create a new message channel
  static Future<Map<String, dynamic>> postChannel(
      List<String> participants) async {
    try {
      // Clear local data cache for channels
      NetworkManager.instance
          .deleteLocalData(name: "channels", type: CacheTypes.list);

      // Send POST request to create a new channel
      var response = await http.post(
        _channelUrl,
        headers: await Config.getDefaultHeadersAuth,
        body: {'participants': jsonEncode(participants)},
      );

      // Handle the response using a custom response handler and return the result
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      throw Exception("Error during post: $e");
    }
  }

  // Method to retrieve the user ID
  static Future<String?> getUserId() async {
    return await storage.getId();
  }

  // Method to send a new message
  static Future<Object> postMessage(String channel, String content, String? img,
      List<dynamic>? fcmToken) async {
    try {
      // Send POST request to send a new message
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

      // Handle the response using a custom response handler and return the result
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      throw Exception("Error during post: $e");
    }
  }

  // Method to retrieve a specific message
  static Future<Object> getMessage(
      String message, String messageNumber, String channel) async {
    try {
      // Send GET request to retrieve a specific message
      var response = await http.get(_messageUrl, headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}',
        'message': message,
        'message_number': messageNumber,
        'channel': channel,
      });

      // Handle the response using a custom response handler and return the result
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      throw Exception("Error during post: $e");
    }
  }

  // Method to retrieve messages for a specific channel
  static Future<List<Object>> getMessages(int page, String channel) async {
    try {
      // Send GET request to retrieve messages for a specific channel
      var response = await http.get(_messagesUrl, headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}',
        'page': page.toString(),
        'channel': channel,
      });

      // Handle the response using a custom response handler and return the result
      return handleResponse(response, Resp.listResponse);
    } catch (e) {
      throw Exception("Error during post: $e");
    }
  }

  // Method to retrieve a list of channels
  static Future<List<Map<String, dynamic>>> getChannels(int page) async {
    try {
      // If requesting the first page, check if there's cached data
      if (page == 0) {
        String? localData = await NetworkManager.instance
            .getLocalData(name: "channels", type: CacheTypes.list);

        // If cached data is available, return it
        if (localData != null) {
          List<Map<String, dynamic>> cachedChannels =
              TypeCasts.stringArrayToJsonArray(localData);
          return cachedChannels;
        }
      }

      // Send GET request to retrieve a list of channels
      var response = await http.get(_channelsUrl, headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}',
        'page': page.toString(),
      });
      List<Map<String, dynamic>> data =
          handleResponse(response, Resp.listResponse);

      // If requesting the first page, save data to the cache
      if (page == 0) {
        NetworkManager.instance
            .saveData(name: "channels", type: CacheTypes.list, data: data);
      }

      return data;
    } catch (e) {
      throw Exception("Error during post: $e");
    }
  }

  // Method to retrieve information about a specific channel
  static Future<Object> getChannel(String channel) async {
    try {
      // Send GET request to retrieve information about a specific channel
      var response = await http.get(_channelUrl, headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}',
        'channel': channel,
      });

      // Handle the response using a custom response handler and return the result
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      throw Exception("Error during API call: $e");
    }
  }

  // Method to retrieve user suggestions
  static Future<List<Map<String, dynamic>>> getSuggestions(int page) async {
    try {
      // Send GET request to retrieve user suggestions
      var response = await http.get(_suggestionsUrl, headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}',
        'page': page.toString(),
      });

      // Handle the response using a custom response handler and return the result
      return handleResponse(response, Resp.listResponse);
    } catch (e) {
      throw Exception("Error during post: $e");
    }
  }
}
