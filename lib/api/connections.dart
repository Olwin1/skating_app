// Import necessary libraries and modules
import 'package:patinka/api/response_handler.dart';
import 'package:patinka/caching/manager.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:convert';
import '../common_logger.dart';

// Define a class called 'ConnectionsAPI'
class ConnectionsAPI {
  // Define static URIs for various connection actions
  static final Uri _followUrl = Uri.parse('${Config.uri}/connections/follow');
  static final Uri _unfollowUrl =
      Uri.parse('${Config.uri}/connections/unfollow');
  static final Uri _friendUrl = Uri.parse('${Config.uri}/connections/friend');
  static final Uri _unfriendUrl =
      Uri.parse('${Config.uri}/connections/unfriend');
  static final Uri _doesFollowUrl = Uri.parse('${Config.uri}/user/follows');
  static final Uri _doesFriendUrl = Uri.parse('${Config.uri}/user/friends');

  // Define a static method to follow a user
  static Future<Map<String, dynamic>> followUser(String user) async {
    try {
      // Delete local cached data related to the user being followed
      NetworkManager.instance
          .deleteLocalData(name: "user-following-$user", type: CacheTypes.list);
      NetworkManager.instance
          .deleteLocalData(name: user, type: CacheTypes.user);

      // Send a POST request to the follow URL with user information
      var response = await http
          .post(_followUrl, headers: await Config.getDefaultHeadersAuth, body: {
        'user': user,
      });

      // Handle and return the response
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // Throw an exception if there's an error during the follow process
      throw Exception("Error during follow: $e");
    }
  }

  // Define a static method to unfollow a user
  static Future<Map<String, dynamic>> unfollowUser(String user) async {
    try {
      // Delete local cached data related to the user being unfollowed
      NetworkManager.instance
          .deleteLocalData(name: "user-following-$user", type: CacheTypes.list);
      NetworkManager.instance
          .deleteLocalData(name: user, type: CacheTypes.user);

      // Send a POST request to the unfollow URL with user information
      var response = await http.post(_unfollowUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {
            'user': user,
          });

      // Handle and return the response
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // Throw an exception if there's an error during the unfollow process
      throw Exception("Error during unfollow: $e");
    }
  }

  // Define a static method to send a friend request
  static Future<Map<String, dynamic>> friendUser(String user) async {
    try {
      // Delete local cached data related to the user's friends
      NetworkManager.instance
          .deleteLocalData(name: "user-friends-$user", type: CacheTypes.list);
      NetworkManager.instance
          .deleteLocalData(name: user, type: CacheTypes.user);

      // Send a POST request to the friend URL with user information
      var response = await http
          .post(_friendUrl, headers: await Config.getDefaultHeadersAuth, body: {
        'user': user,
      });

      // Handle and return the response
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // Throw an exception if there's an error during the friend request process
      throw Exception("Error during friend: $e");
    }
  }

  // Define a static method to unfriend a user
  static Future<Map<String, dynamic>> unfriendUser(String user) async {
    try {
      // Delete local cached data related to the user's friends
      NetworkManager.instance
          .deleteLocalData(name: "user-friends-$user", type: CacheTypes.list);
      NetworkManager.instance
          .deleteLocalData(name: user, type: CacheTypes.user);

      // Send a POST request to the unfriend URL with user information
      var response = await http.post(_unfriendUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {
            'user': user,
          });

      // Handle and return the response
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // Throw an exception if there's an error during the unfriend process
      throw Exception("Error during unfriend: $e");
    }
  }

  // Define a static method to respond to a follow request
  static Future<Map<String, dynamic>> followUserRequest(
      String user, bool accepted) async {
    try {
      // Delete local cached data related to the user's follow requests
      NetworkManager.instance
          .deleteLocalData(name: "user-following-$user", type: CacheTypes.list);
      NetworkManager.instance
          .deleteLocalData(name: user, type: CacheTypes.user);

      // Send a PATCH request to the follow URL with user information and acceptance status
      var response = await http.patch(_followUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {'user': user, 'accepted': accepted.toString()});

      // Handle and return the response
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // Throw an exception if there's an error during the response to follow request
      throw Exception("Error during responding to follow request: $e");
    }
  }

  // Define a static method to respond to a friend request
  static Future<Map<String, dynamic>> friendUserRequest(
      String user, bool accepted) async {
    try {
      // Delete local cached data related to the user's friend requests
      NetworkManager.instance
          .deleteLocalData(name: "user-friends-$user", type: CacheTypes.list);
      NetworkManager.instance
          .deleteLocalData(name: user, type: CacheTypes.user);

      // Send a PATCH request to the friend URL with user information and acceptance status
      var response = await http.patch(_friendUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {'user': user, 'accepted': accepted.toString()});

      // Handle and return the response
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // Throw an exception if there's an error during the response to friend request
      throw Exception("Error during friend request response: $e");
    }
  }

  // Define a static method to check if the user follows another user
  static Future<List<bool>> doesFollow(String user) async {
    try {
      // Send a GET request to the follow check URL with user information
      var response = await http.get(_doesFollowUrl, headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}',
        'user': user
      });

      // Check the response status code
      if (response.statusCode == 200) {
        commonLogger.v("Response: 200 Does Follow User");

        // Parse the response body and return the result
        List<bool> result = List<bool>.from(jsonDecode(response.body));
        return result;
      } else if (response.statusCode == 404) {
        return [false];
      } else {
        // Throw an exception if the follow check is unsuccessful
        throw Exception("Follow check Unsuccessful: ${response.reasonPhrase}");
      }
    } catch (e) {
      // Throw an exception if there's an error during the follow check process
      throw Exception("Error during follow check: $e");
    }
  }

  // Define a static method to check if the user is friends with another user
  static Future<List<bool>> doesFriend(String user) async {
    try {
      // Send a GET request to the friend check URL with user information
      var response = await http.get(_doesFriendUrl, headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}',
        'user': user
      });

      // Check the response status code
      if (response.statusCode == 200) {
        commonLogger.v("Response: 200 Does Friend User");

        // Parse the response body and return the result
        List<dynamic>? result = jsonDecode(response.body);

        if (result == null) {
          return [false];
        }

        return [
          result[0],
          result.length > 1 ? result[1] : false,
          result.length > 2 ? result[2] : false
        ];
      } else if (response.statusCode == 404) {
        return [false];
      } else {
        // Throw an exception if the friend check is unsuccessful
        throw Exception("Friend check Unsuccessful: ${response.reasonPhrase}");
      }
    } catch (e) {
      // Throw an exception if there's an error during the friend check process
      throw Exception("Error during friend check: $e");
    }
  }
}
