import 'package:patinka/api/response_handler.dart';
import 'package:patinka/caching/manager.dart';

// Import necessary dependencies and files
import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:convert';
import '../common_logger.dart';

class ConnectionsAPI {
  static final Uri _followUrl = Uri.parse('${Config.uri}/connections/follow');
  static final Uri _unfollowUrl =
      Uri.parse('${Config.uri}/connections/unfollow');
  static final Uri _friendUrl = Uri.parse('${Config.uri}/connections/friend');
  static final Uri _unfriendUrl =
      Uri.parse('${Config.uri}/connections/unfriend');
  static final Uri _doesFollowUrl = Uri.parse('${Config.uri}/user/follows');
  static final Uri _doesFriendUrl = Uri.parse('${Config.uri}/user/friends');
// This method is used to follow a user
  static Future<Map<String, dynamic>> followUser(String user) async {
    // Set the API endpoint URL
    try {
      NetworkManager.instance
          .deleteLocalData(name: "user-following-$user", type: CacheTypes.list);
      NetworkManager.instance
          .deleteLocalData(name: user, type: CacheTypes.user);
      // Send a POST request to the endpoint with the user to follow
      var response = await http
          .post(_followUrl, headers: await Config.getDefaultHeadersAuth, body: {
        'user': user,
      });

      // If the request was successful (status code 200), parse the response body and return it
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // If there was an error while sending the request, throw an exception with the error message
      throw Exception("Error during follow: $e");
    }
  }

// This method is used to follow a user
  static Future<Map<String, dynamic>> unfollowUser(String user) async {
    // Set the API endpoint URL
    try {
      NetworkManager.instance
          .deleteLocalData(name: "user-following-$user", type: CacheTypes.list);
      NetworkManager.instance
          .deleteLocalData(name: user, type: CacheTypes.user);
      // Send a POST request to the endpoint with the user to follow
      var response = await http.post(_unfollowUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {
            'user': user,
          });

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // If there was an error while sending the request, throw an exception with the error message
      throw Exception("Error during unfollow: $e");
    }
  }

// This method is used to friend a user
  static Future<Map<String, dynamic>> friendUser(String user) async {
    // Set the API endpoint URL
    try {
      NetworkManager.instance
          .deleteLocalData(name: "user-friends-$user", type: CacheTypes.list);
      NetworkManager.instance
          .deleteLocalData(name: user, type: CacheTypes.user);
      // Send a POST request to the endpoint with the user to friend
      var response = await http
          .post(_friendUrl, headers: await Config.getDefaultHeadersAuth, body: {
        'user': user,
      });
      // If the request was successful (status code 200), parse the response body and return it
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // If there was an error while sending the request, throw an exception with the error message
      throw Exception("Error during friend: $e");
    }
  }

// This method is used to follow a user
  static Future<Map<String, dynamic>> unfriendUser(String user) async {
    // Set the API endpoint URL
    try {
      NetworkManager.instance
          .deleteLocalData(name: "user-friends-$user", type: CacheTypes.list);
      NetworkManager.instance
          .deleteLocalData(name: user, type: CacheTypes.user);
      // Send a POST request to the endpoint with the user to follow
      var response = await http.post(_unfriendUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {
            'user': user,
          });

      // If the request was successful (status code 200), parse the response body and return it
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // If there was an error while sending the request, throw an exception with the error message
      throw Exception("Error during unfriend: $e");
    }
  }

// This function sends a PATCH request to follow a user and returns a Future that resolves to a Map<String, dynamic> response
  static Future<Map<String, dynamic>> followUserRequest(
      String user, bool accepted) async {
    try {
      NetworkManager.instance
          .deleteLocalData(name: "user-following-$user", type: CacheTypes.list);
      NetworkManager.instance
          .deleteLocalData(name: user, type: CacheTypes.user);
      var response = await http.patch(_followUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {
            'user':
                user, // Include the ID of the user to be followed in the request body
            'accepted': accepted
                .toString() // Include whether the follow request has been accepted or not in the request body
          });
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      throw Exception(
          "Error during responding to follow request: $e"); // Throw an exception if an error occurred while processing the request
    }
  }

// This function sends a PATCH request to friend a user and returns a Future that resolves to a Map<String, dynamic> response
  static Future<Map<String, dynamic>> friendUserRequest(
      String user, bool accepted) async {
    try {
      NetworkManager.instance
          .deleteLocalData(name: "user-friends-$user", type: CacheTypes.list);
      NetworkManager.instance
          .deleteLocalData(name: user, type: CacheTypes.user);
      var response = await http.patch(_friendUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {
            'user':
                user, // Include the ID of the user to be friended in the request body
            'accepted': accepted
                .toString() // Include whether the friend request has been accepted or not in the request body
          });
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      throw Exception(
          "Error during friend request response: $e"); // Throw an exception if an error occurred while processing the request
    }
  }

// This function takes in a user id as input and checks whether the current user follows that user or not.
  static Future<List<bool>> doesFollow(String user) async {
    // Create a URL object to send the request to the server.
    try {
      // Send a GET request to the server with the required headers and user data.
      var response = await http.get(_doesFollowUrl, headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}',
        'user': user
      });
      // If the server returns a status code of 200, decode the response body into a list of booleans and return it.
      if (response.statusCode == 200) {
        commonLogger.v("Response: 200 Does Follow User");

        List<bool> result = List<bool>.from(jsonDecode(response.body));
        return result;
        // If the server returns a status code of 404, return a list containing false (as the user doesn't exist).
      } else if (response.statusCode == 404) {
        return [false];
        // If any other status code is returned, throw an exception with the reason phrase.
      } else {
        throw Exception("Follow check Unsuccessful: ${response.reasonPhrase}");
      }
    } catch (e) {
      // If there is an error during the request, throw an exception with the error message.
      throw Exception("Error during follow check: $e");
    }
  }

// This function takes in a user id as input and checks whether the current user is friends with that user or not.
  static Future<List<bool>> doesFriend(String user) async {
    // Create a URL object to send the request to the server.
    try {
      // Send a GET request to the server with the required headers and user data.
      var response = await http.get(_doesFriendUrl, headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}',
        'user': user
      });
      // If the server returns a status code of 200, decode the response body into a map of strings and dynamic values.
      if (response.statusCode == 200) {
        commonLogger.v("Response: 200 Does Friend User");

        List<dynamic>? result = jsonDecode(response.body);
        // If the result is null, return a list containing false (as the user doesn't exist).
        if (result == null) {
          return [false];
        }

        // Otherwise, return a list containing true (as the users are friends) and a boolean indicating if the user has requested the friendship.
        return [
          result[0],
          result.length > 1 ? result[1] : false,
          result.length > 2 ? result[2] : false
        ];
        // If the server returns a status code of 404, return a list containing false (as the user doesn't exist).
      } else if (response.statusCode == 404) {
        return [false];
        // If any other status code is returned, throw an exception with the reason phrase.
      } else {
        throw Exception("Friend check Unsuccessful: ${response.reasonPhrase}");
      }
    } catch (e) {
      // If there is an error during the request, throw an exception with the error message.
      throw Exception("Error during friend check: $e");
    }
  }
}
