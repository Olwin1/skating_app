import 'package:email_validator/email_validator.dart';
import 'package:patinka/api/response_handler.dart';
import 'package:patinka/api/type_casts.dart';
import 'package:patinka/caching/manager.dart';
import 'package:patinka/common_logger.dart';

import 'token.dart';

// Import necessary dependencies and files
import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:convert';

// Export login and signup functions from auth.dart
export 'package:patinka/api/social.dart'
    show
        delComment,
        delPost,
        dislikeComment,
        getComment,
        getComments,
        getPost,
        getPosts,
        likeComment,
        likePost,
        postComment,
        postPost,
        savePost,
        undislikeComment,
        unlikeComment,
        unlikePost,
        unsavePost;

SecureStorage storage = SecureStorage();

/*
{
    "description": "user3-postt",
    "like_users": [],
    "comments": [],
    "author": "64209a87a90fe2b82d180c08",
    "image": "6425752bbbbf84c6d9fdb98d",
    "date": "2023-04-11T15:25:13.000Z",
    "_id": "64357bd9cd6ed284e9946471",
    "__v": 0
}
*/

// Define a function to authenticate user credentials and return a token
Future<Map<String, dynamic>> postPost(String description, String image) async {
  // Define the URL endpoint for login
  var url = Uri.parse('${Config.uri}/post/post');

  try {
    // Make a POST request to the login endpoint with the user's credentials
    var response = await http.post(
      url,
      headers: await Config.getDefaultHeadersAuth,
      body: {'description': description, 'image': image},
    );
    String? id = await storage.getId();
    if (id != null) {
      NetworkManager.instance
          .deleteLocalData(name: "user-posts-$id", type: CacheTypes.list);
    }
    // If the response is successful, extract the token from the response body and return it
    return ResponseHandler.handleResponse(response);
  } catch (e) {
    // If there is an error during login, throw an exception with the error message
    throw Exception("Error during post: $e");
  }
}

// Get a single post by its ID
Future<Map<String, dynamic>> getPost(String post) async {
  // Define the URL for the HTTP request
  var url = Uri.parse('${Config.uri}/post/post');

  try {
    // Make a GET request to the specified URL with headers and parameters
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}',
        'post': post
      },
    );

    // If the response status code is 200 OK, parse and return the response body as a Map
    return ResponseHandler.handleResponse(response);
  } catch (e) {
    // If there's an error, throw an exception with the error message
    throw Exception("Error during post: $e");
  }
}

// Get a list of posts, excluding those with IDs in the "seen" list
Future<List<Map<String, dynamic>>> getPosts(List<String> seen) async {
  String seenPosts = jsonEncode(seen);
  if (seen.isEmpty) {
    String? localData = await NetworkManager.instance
        .getLocalData(name: "posts", type: CacheTypes.list);

    if (localData != null) {
      List<Map<String, dynamic>> cachedPosts =
          TypeCasts.stringArrayToJsonArray(localData);
      return cachedPosts;
    }
    commonLogger.d(localData);
    commonLogger.d("localData");
  }
  // Define the URL for the HTTP request
  var url = Uri.parse('${Config.uri}/post/posts');

  try {
    // Make a POST request to the specified URL with headers and parameters
    var response = await http.post(
      url,
      headers: await Config.getDefaultHeadersAuth,
      body: {'seen': seenPosts},
    );
    List<Map<String, dynamic>> data =
        ResponseHandler.handleListResponse(response);
    if (seen.isEmpty) {
      NetworkManager.instance
          .saveData(name: "posts", type: CacheTypes.list, data: data);
    }
    // If the response status code is 200 OK, parse and return the response body as a Map
    return data;
  } catch (e) {
    // If there's an error, throw an exception with the error message
    throw Exception("Error during post: $e");
  }
}

// Delete a single post by its ID
Future<Map<String, dynamic>> delPost(String post) async {
  // Define the URL for the HTTP request
  var url = Uri.parse('${Config.uri}/post/post');

  try {
    // Make a DELETE request to the specified URL with headers and parameters
    var response = await http.delete(
      url,
      headers: await Config.getDefaultHeadersAuth,
      body: {'post': post},
    );
    String? id = await storage.getId();
    if (id != null) {
      await NetworkManager.instance
          .deleteLocalData(name: "user-posts-$id", type: CacheTypes.list);
    }

    // If the response status code is 200 OK, parse and return the response body as a Map
    return ResponseHandler.handleResponse(response);
  } catch (e) {
    // If there's an error, throw an exception with the error message
    throw Exception("Error during post: $e");
  }
}

// This function retrieves comments for a given post and page number
// It returns a Future<Map<String, dynamic>> which resolves to a Map<String, dynamic> representing the comments
Future<List<Map<String, dynamic>>> getComments(String post, int page) async {
  var url = Uri.parse('${Config.uri}/post/comments');

  try {
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization':
            'Bearer ${await storage.getToken()}', // Include authentication token in the header
        'post': post, // Specify the post ID to retrieve comments for
        'page':
            page.toString(), // Specify the page number of comments to retrieve
      },
    );

    return ResponseHandler.handleListResponse(response);
  } catch (e) {
    throw Exception(
        "Error during post: $e"); // Throw an exception if there is an error during the request
  }
}

// This function retrieves a single comment for a given comment ID
// It returns a Future<Map<String, dynamic>> which resolves to a Map<String, dynamic> representing the comment
Future<Map<String, dynamic>> getComment(String comment) async {
  var url = Uri.parse('${Config.uri}/post/comment');

  try {
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization':
            'Bearer ${await storage.getToken()}', // Include authentication token in the header
        'comment': comment // Specify the comment ID to retrieve
      },
    );

    return ResponseHandler.handleResponse(response);
  } catch (e) {
    throw Exception(
        "Error during post: $e"); // Throw an exception if there is an error during the request
  }
}

// Function to like a comment using HTTP POST request
Future<Map<String, dynamic>> likeComment(String comment) async {
  // Define the URL for the API endpoint
  var url = Uri.parse('${Config.uri}/post/like_comment');

  try {
    // Send the HTTP POST request with the comment data and authentication headers
    var response = await http.post(url,
        headers: await Config.getDefaultHeadersAuth,
        body: {'comment': comment});

    return ResponseHandler.handleResponse(response);
  } catch (e) {
    // If there is an error with the HTTP request, throw an exception with the error message
    throw Exception("Error during post: $e");
  }
}

// Function to dislike a comment using HTTP POST request
Future<Map<String, dynamic>> dislikeComment(String comment) async {
  // Define the URL for the API endpoint
  var url = Uri.parse('${Config.uri}/post/dislike_comment');

  try {
    // Send the HTTP POST request with the comment data and authentication headers
    var response = await http.post(url,
        headers: await Config.getDefaultHeadersAuth,
        body: {'comment': comment});

    // If the response status code is 200 OK, parse the JSON response body and return it
    return ResponseHandler.handleResponse(response);
  } catch (e) {
    // If there is an error with the HTTP request, throw an exception with the error message
    throw Exception("Error during post: $e");
  }
}

// This function is used to unlike a comment on a post.
Future<Map<String, dynamic>> unlikeComment(String comment) async {
  var url = Uri.parse('${Config.uri}/post/unlike_comment');

  try {
    var response = await http.post(url,
        headers: await Config.getDefaultHeadersAuth,
        body: {'comment': comment});

    return ResponseHandler.handleResponse(response);
  } catch (e) {
    // Catch any exceptions that occur during the post and throw a new exception with the error message.
    throw Exception("Error during post: $e");
  }
}

// This function is used to undislike a comment on a post.
Future<Map<String, dynamic>> undislikeComment(String comment) async {
  var url = Uri.parse('${Config.uri}/post/undislike_comment');

  try {
    var response = await http.post(url,
        headers: await Config.getDefaultHeadersAuth,
        body: {'comment': comment});

    return ResponseHandler.handleResponse(response);
  } catch (e) {
    // Catch any exceptions that occur during the post and throw a new exception with the error message.
    throw Exception("Error during post: $e");
  }
}

// This function is used to delete a comment on a post.
Future<Map<String, dynamic>> delComment(String comment) async {
  var url = Uri.parse('${Config.uri}/post/comment');

  try {
    var response = await http.delete(url,
        headers: await Config.getDefaultHeadersAuth,
        body: {'comment': comment});
    return ResponseHandler.handleResponse(response);
  } catch (e) {
    // Catch any exceptions that occur during the post and throw a new exception with the error message.
    throw Exception("Error during post: $e");
  }
}

Future<Map<String, dynamic>> postComment(String post, String content) async {
  // The method takes two parameters: the post ID and the content of the comment to be posted.
  var url = Uri.parse('${Config.uri}/post/comment');

  try {
    // The code tries to make an HTTP POST request to the given URL with the given headers and body parameters.
    var response = await http.post(url,
        headers: await Config.getDefaultHeadersAuth,
        body: {'post': post, 'content': content});

    return ResponseHandler.handleResponse(response);
  } catch (e) {
    // If there is any other error during the HTTP request, it throws an Exception with a message containing the error.
    throw Exception("Error during post: $e");
  }
}

Future<Map<String, dynamic>> savePost(String post) async {
  // The method takes one parameter: the post ID to be saved.
  var url = Uri.parse('${Config.uri}/post/save');

  try {
    // The code tries to make an HTTP POST request to the given URL with the given headers and body parameters.
    var response = await http
        .post(url, headers: await Config.getDefaultHeadersAuth, body: {
      'post': post,
    });

    return ResponseHandler.handleResponse(response);
  } catch (e) {
    // If there is any other error during the HTTP request, it throws an Exception with a message containing the error.
    throw Exception("Error during post: $e");
  }
}

Future<Map<String, dynamic>> unsavePost(String post) async {
  // function to unsave a post
  var url = Uri.parse('${Config.uri}/post/unsave'); // endpoint URL

  try {
    var response = await http
        .post(url, headers: await Config.getDefaultHeadersAuth, body: {
      'post': post, // include the post ID in the request body
    });

    return ResponseHandler.handleResponse(response);
  } catch (e) {
    // handle any exceptions that occur during the HTTP request
    throw Exception(
        "Error during post: $e"); // throw an exception with the error message
  }
}

Future<Map<String, dynamic>> likePost(String post) async {
  // function to like a post
  var url = Uri.parse('${Config.uri}/post/like'); // endpoint URL

  try {
    var response = await http
        .post(url, headers: await Config.getDefaultHeadersAuth, body: {
      'post': post, // include the post ID in the request body
    });

    return ResponseHandler.handleResponse(response);
  } catch (e) {
    // handle any exceptions that occur during the HTTP request
    throw Exception(
        "Error during post: $e"); // throw an exception with the error message
  }
}

Future<Map<String, dynamic>> unlikePost(String post) async {
  // function to unlike a post
  var url = Uri.parse('${Config.uri}/post/unlike'); // endpoint URL

  try {
    var response = await http
        .post(url, headers: await Config.getDefaultHeadersAuth, body: {
      'post': post, // include the post ID in the request body
    });

    return ResponseHandler.handleResponse(response);
  } catch (e) {
    // handle any exceptions that occur during the HTTP request
    throw Exception(
        "Error during post: $e"); // throw an exception with the error message
  }
}

Future<Map<String, dynamic>> getUser(String id) async {
  // Specifying that the function returns a future object of a Map object with key-value pairs of type string-dynamic

  var url = Uri.parse(
      '${Config.uri}/user/'); // Creating a variable 'url' and assigning it the value of the URI of the specified string

  try {
    // Using a try-catch block to handle errors
    String? localData = await NetworkManager.instance
        .getLocalData(name: id, type: CacheTypes.user);

    if (localData != null) {
      Map<String, dynamic> cachedUser = TypeCasts.stringToJson(localData);
      return cachedUser;
    }
    var response = await http.get(
      // Creating a variable 'response' and making a post request to the specified URL
      url,
      headers: {
        'Content-Type':
            'application/x-www-form-urlencoded', // Specifying the headers for the request
        'Authorization':
            'Bearer ${await storage.getToken()}', // Including the authorization token
        'id': id,
      },
    );
    Map<String, dynamic> data = ResponseHandler.handleResponse(response);
    if (data["avatar"] == null) {
      data["avatar"] = "default";
    }
    await NetworkManager.instance
        .saveData(name: id, type: CacheTypes.user, data: data);

    return data;
  } catch (e) {
    // Handling the error
    throw Exception(
        "Error during post: $e"); // Throwing an exception with an error message
  }
}

Future<List<Map<String, dynamic>>> getUserPosts(String userId, int page) async {
  // Specifying that the function returns a future object of a Map object with key-value pairs of type string-dynamic

  var url = Uri.parse(
      '${Config.uri}/post/user_posts'); // Creating a variable 'url' and assigning it the value of the URI of the specified string

  try {
    String? localData = await NetworkManager.instance
        .getLocalData(name: "user-posts-$userId", type: CacheTypes.list);

    if (localData != null) {
      List<Map<String, dynamic>> cachedPosts =
          TypeCasts.stringArrayToJsonArray(localData);
      return cachedPosts;
    }
    // Using a try-catch block to handle errors
    var response = await http.get(
      // Creating a variable 'response' and making a post request to the specified URL
      url,
      headers: {
        'Content-Type':
            'application/x-www-form-urlencoded', // Specifying the headers for the request
        'Authorization':
            'Bearer ${await storage.getToken()}', // Including the authorization token
        'page': page.toString(),
        'user': userId
      },
    );
    List<Map<String, dynamic>> data =
        ResponseHandler.handleListResponse(response);
    await NetworkManager.instance.saveData(
        name: "user-posts-$userId", type: CacheTypes.list, data: data);

    return data;
  } catch (e) {
    // Handling the error
    throw Exception(
        "Error during post: $e"); // Throwing an exception with an error message
  }
}

Future<List<Map<String, dynamic>>> getUserFollowing(
    int page, Map<String, dynamic>? user) async {
  // Specifying that the function returns a future object of a Map object with key-value pairs of type string-dynamic

  var url = Uri.parse(
      '${Config.uri}/connections/following'); // Creating a variable 'url' and assigning it the value of the URI of the specified string

  try {
    String userId = user?['_id'] ?? await storage.getId();
    String? localData = await NetworkManager.instance
        .getLocalData(name: "user-following-$userId", type: CacheTypes.list);

    if (localData != null) {
      List<Map<String, dynamic>> cachedUsers =
          TypeCasts.stringArrayToJsonArray(localData);
      return cachedUsers;
    }
    // Using a try-catch block to handle errors
    Map<String, String> headers = {
      'Content-Type':
          'application/x-www-form-urlencoded', // Specifying the headers for the request
      'Authorization':
          'Bearer ${await storage.getToken()}', // Including the authorization token
      'page': page.toString(),
    };
    if (user?["_id"] != null) {
      headers['user'] = user!["_id"];
    }
    var response = await http.get(
        // Creating a variable 'response' and making a post request to the specified URL
        url,
        headers: headers);
    List<Map<String, dynamic>> data =
        ResponseHandler.handleListResponse(response);
    await NetworkManager.instance.saveData(
        name: "user-following-$userId", type: CacheTypes.list, data: data);

    return data;
  } catch (e) {
    // Handling the error
    throw Exception(
        "Error during post: $e"); // Throwing an exception with an error message
  }
}

Future<List<Map<String, dynamic>>> getUserFollowers(
    int page, Map<String, dynamic>? user) async {
  // Specifying that the function returns a future object of a Map object with key-value pairs of type string-dynamic
  String userId = user?['_id'] ?? await storage.getId();

  String? localData = await NetworkManager.instance
      .getLocalData(name: "user-followers-$userId", type: CacheTypes.list);

  if (localData != null) {
    List<Map<String, dynamic>> cachedUsers =
        TypeCasts.stringArrayToJsonArray(localData);
    return cachedUsers;
  }

  var url = Uri.parse(
      '${Config.uri}/connections/followers'); // Creating a variable 'url' and assigning it the value of the URI of the specified string

  try {
    // Using a try-catch block to handle errors
    Map<String, String> headers = {
      'Content-Type':
          'application/x-www-form-urlencoded', // Specifying the headers for the request
      'Authorization':
          'Bearer ${await storage.getToken()}', // Including the authorization token
      'page': page.toString(),
    };
    if (user?["_id"] != null) {
      headers['user'] = user!["_id"];
    }
    var response = await http.get(
        // Creating a variable 'response' and making a post request to the specified URL
        url,
        headers: headers);
    List<Map<String, dynamic>> data =
        ResponseHandler.handleListResponse(response);
    await NetworkManager.instance.saveData(
        name: "user-followers-$userId", type: CacheTypes.list, data: data);

    return data;
  } catch (e) {
    // Handling the error
    throw Exception(
        "Error during post: $e"); // Throwing an exception with an error message
  }
}

Future<List<Map<String, dynamic>>> getUserFriends(
    int page, Map<String, dynamic>? user) async {
  // Specifying that the function returns a future object of a Map object with key-value pairs of type string-dynamic
  String userId = user?['_id'] ?? await storage.getId();

  String? localData = await NetworkManager.instance
      .getLocalData(name: "user-friends-$userId", type: CacheTypes.list);

  if (localData != null) {
    List<Map<String, dynamic>> cachedUsers =
        TypeCasts.stringArrayToJsonArray(localData);
    return cachedUsers;
  }

  var url = Uri.parse(
      '${Config.uri}/connections/friends'); // Creating a variable 'url' and assigning it the value of the URI of the specified string

  try {
    // Using a try-catch block to handle errors
    Map<String, String> headers = {
      'Content-Type':
          'application/x-www-form-urlencoded', // Specifying the headers for the request
      'Authorization':
          'Bearer ${await storage.getToken()}', // Including the authorization token
      'page': page.toString(),
    };
    if (user?["_id"] != null) {
      headers['user'] = user!["_id"];
    }
    var response = await http.get(
        // Creating a variable 'response' and making a post request to the specified URL
        url,
        headers: headers);
    List<Map<String, dynamic>> data =
        ResponseHandler.handleListResponse(response);
    await NetworkManager.instance.saveData(
        name: "user-friends-$userId", type: CacheTypes.list, data: data);
    return data;
  } catch (e) {
    // Handling the error
    throw Exception(
        "Error during post: $e"); // Throwing an exception with an error message
  }
}

// Search
Future<List<Map<String, dynamic>>> searchUsers(String query) async {
  // Define the URL for the HTTP request
  var url = Uri.parse('${Config.uri}/user/search');

  try {
    // Make a POST request to the specified URL with headers and parameters
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}',
        'query': query
      },
    );

    // If the response status code is 200 OK, parse and return the response body as a Map
    return ResponseHandler.handleListResponse(response);
  } catch (e) {
    // If there's an error, throw an exception with the error message
    throw Exception("Error during post: $e");
  }
}

Future<Map<String, dynamic>> setEmail(String email) async {
  // Specifying that the function returns a future object of a Map object with key-value pairs of type string-dynamic
  if (!EmailValidator.validate(email)) throw Exception("Invalid Email");
  var url = Uri.parse(
      '${Config.uri}/user/email'); // Creating a variable 'url' and assigning it the value of the URI of the specified string

  try {
    // Using a try-catch block to handle errors
    var response = await http.post(
        // Creating a variable 'response' and making a post request to the specified URL
        url,
        headers: await Config.getDefaultHeadersAuth,
        body: {
          'email': email,
        });

    return ResponseHandler.handleResponse(response);
  } catch (e) {
    // Handling the error
    throw Exception(
        "Error during post: $e"); // Throwing an exception with an error message
  }
}

Future<Map<String, dynamic>> setDescription(String desc) async {
  // Specifying that the function returns a future object of a Map object with key-value pairs of type string-dynamic
  if (desc.length > 250) throw Exception("Invalid Description");
  var url = Uri.parse(
      '${Config.uri}/user/description'); // Creating a variable 'url' and assigning it the value of the URI of the specified string

  try {
    // Using a try-catch block to handle errors
    var response = await http.post(
        // Creating a variable 'response' and making a post request to the specified URL
        url,
        headers: await Config.getDefaultHeadersAuth,
        body: {
          'description': desc,
        });

    return ResponseHandler.handleResponse(response);
  } catch (e) {
    // Handling the error
    throw Exception(
        "Error during post: $e"); // Throwing an exception with an error message
  }
}

Future<Map<String, dynamic>> setAvatar(String avatar) async {
  // Specifying that the function returns a future object of a Map object with key-value pairs of type string-dynamic
  var url = Uri.parse(
      '${Config.uri}/user/avatar'); // Creating a variable 'url' and assigning it the value of the URI of the specified string

  try {
    // Using a try-catch block to handle errors
    var response = await http.post(
        // Creating a variable 'response' and making a post request to the specified URL
        url,
        headers: await Config.getDefaultHeadersAuth,
        body: {
          'avatar': avatar,
        });

    return ResponseHandler.handleResponse(response);
  } catch (e) {
    // Handling the error
    throw Exception(
        "Error during post: $e"); // Throwing an exception with an error message
  }
}
