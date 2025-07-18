// Import necessary dependencies and files
import "dart:async";

import "package:email_validator/email_validator.dart";
import "package:http/http.dart" as http;
import "package:patinka/api/config/config.dart";
import "package:patinka/api/response_handler.dart";
import "package:patinka/api/type_casts.dart";
import "package:patinka/caching/manager.dart";
import "package:patinka/common_logger.dart";

class SocialAPI {
  static final Uri _postUrl = Uri.parse("${Config.uri}/post/post");
  static final Uri _postsUrl = Uri.parse("${Config.uri}/post/posts");
  static final Uri _commentsUrl = Uri.parse("${Config.uri}/post/comments");
  static final Uri _commentUrl = Uri.parse("${Config.uri}/post/comment");
  static final Uri _likeCommentUrl =
      Uri.parse("${Config.uri}/post/like_comment");
  static final Uri _dislikeCommentUrl =
      Uri.parse("${Config.uri}/post/dislike_comment");
  static final Uri _unlikeCommentUrl =
      Uri.parse("${Config.uri}/post/unlike_comment");
  static final Uri _undislikeCommentUrl =
      Uri.parse("${Config.uri}/post/undislike_comment");
  static final Uri _savePostUrl = Uri.parse("${Config.uri}/post/save");
  static final Uri _unsavePostUrl = Uri.parse("${Config.uri}/post/unsave");
  static final Uri _likePostUrl = Uri.parse("${Config.uri}/post/like");
  static final Uri _unlikePostUrl = Uri.parse("${Config.uri}/post/unlike");
  static final Uri _userUrl = Uri.parse("${Config.uri}/user");
  static final Uri _userPostsUrl = Uri.parse("${Config.uri}/post/user_posts");
  static final Uri _userFollowing =
      Uri.parse("${Config.uri}/connections/following");
  static final Uri _userFollowers =
      Uri.parse("${Config.uri}/connections/followers");
  static final Uri _userFriends =
      Uri.parse("${Config.uri}/connections/friends");
  static final Uri _searchUsersUrl = Uri.parse("${Config.uri}/user/search");
  static final Uri _userEmailUrl = Uri.parse("${Config.uri}/user/email");
  static final Uri _userDescriptionUrl =
      Uri.parse("${Config.uri}/user/description");
  static final Uri _userAvatarUrl = Uri.parse("${Config.uri}/user/avatar");
  static final Uri _savedPostsUrl = Uri.parse("${Config.uri}/post/saved");

// Define a function to authenticate user credentials and return a token
  static Future<Map<String, dynamic>> postPost(
      final String description, final String image) async {
    // Define the URL endpoint for login

    try {
      // Make a POST request to the login endpoint with the user's credentials
      final response = await http.post(
        _postUrl,
        headers: await Config.getDefaultHeadersAuth,
        body: {"description": description, "image": image},
      );
      final String? id = await storage.getId();
      if (id != null) {
        unawaited(NetworkManager.instance
            .deleteLocalData(name: "user-posts-$id", type: CacheTypes.list));
      }
      // If the response is successful, extract the token from the response body and return it
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // If there is an error during login, throw an exception with the error message
      throw Exception("Error during post: $e");
    }
  }

// Get a single post by its ID
  static Future<Map<String, dynamic>> getPost(final String post) async {
    // Define the URL for the HTTP request

    try {
      // Make a GET request to the specified URL with headers and parameters
      final response = await http.get(
        _postUrl,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Bearer ${await storage.getToken()}",
          "post": post
        },
      );

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // If there's an error, throw an exception with the error message
      throw Exception("Error during post: $e");
    }
  }

// Get a list of posts, excluding those with IDs in the "seen" list
  static Future<List<Map<String, dynamic>>> getPosts(final int pageKey) async {
    //String seenPosts = jsonEncode(seen);
    if (pageKey == 0) {
      final String? localData = await NetworkManager.instance
          .getLocalData(name: "posts", type: CacheTypes.list);

      if (localData != null) {
        final List<Map<String, dynamic>> cachedPosts =
            TypeCasts.stringArrayToJsonArray(localData);
        return cachedPosts;
      }
      commonLogger
        ..d(localData)
        ..d("localData");
    }
    // Define the URL for the HTTP request

    try {
      // Make a POST request to the specified URL with headers and parameters
      final response = await http.post(
        _postsUrl,
        headers: await Config.getDefaultHeadersAuth,
        body: {"page": pageKey.toString()},
      );
      final List<Map<String, dynamic>> data =
          ResponseHandler.handleListResponse(response);
      if (pageKey == 0) {
        unawaited(NetworkManager.instance
            .saveData(name: "posts", type: CacheTypes.list, data: data));
      }
      // If the response status code is 200 OK, parse and return the response body as a Map
      return data;
    } catch (e) {
      // If there's an error, throw an exception with the error message
      throw Exception("Error during post: $e");
    }
  }

// Delete a single post by its ID
  static Future<Map<String, dynamic>> delPost(final String post) async {
    // Define the URL for the HTTP request

    try {
      // Make a DELETE request to the specified URL with headers and parameters
      final response = await http.delete(
        _postUrl,
        headers: await Config.getDefaultHeadersAuth,
        body: {"post": post},
      );
      final String? id = await storage.getId();
      if (id != null) {
        await NetworkManager.instance
            .deleteLocalData(name: "user-posts-$id", type: CacheTypes.list);
      }

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // If there's an error, throw an exception with the error message
      throw Exception("Error during post: $e");
    }
  }

// This function retrieves comments for a given post and page number
// It returns a static Future<Map<String, dynamic>> which resolves to a Map<String, dynamic> representing the comments
  static Future<List<Map<String, dynamic>>> getComments(
      final String post, final int page) async {
    try {
      final response = await http.get(
        _commentsUrl,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization":
              "Bearer ${await storage.getToken()}", // Include authentication token in the header
          "post": post, // Specify the post ID to retrieve comments for
          "page": page
              .toString(), // Specify the page number of comments to retrieve
        },
      );
      return handleResponse(response, Resp.listResponse);
    } catch (e) {
      throw Exception(
          "Error during post: $e"); // Throw an exception if there is an error during the request
    }
  }

// This function retrieves a single comment for a given comment ID
// It returns a static Future<Map<String, dynamic>> which resolves to a Map<String, dynamic> representing the comment
  static Future<Map<String, dynamic>> getComment(final String comment) async {
    try {
      final response = await http.get(
        _commentUrl,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization":
              "Bearer ${await storage.getToken()}", // Include authentication token in the header
          "comment": comment // Specify the comment ID to retrieve
        },
      );

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      throw Exception(
          "Error during post: $e"); // Throw an exception if there is an error during the request
    }
  }

// Function to like a comment using HTTP POST request
  static Future<Map<String, dynamic>> likeComment(final String comment) async {
    // Define the URL for the API endpoint

    try {
      // Send the HTTP POST request with the comment data and authentication headers
      final response = await http.post(_likeCommentUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {"comment": comment});

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // If there is an error with the HTTP request, throw an exception with the error message
      throw Exception("Error during post: $e");
    }
  }

// Function to dislike a comment using HTTP POST request
  static Future<Map<String, dynamic>> dislikeComment(
      final String comment) async {
    // Define the URL for the API endpoint

    try {
      // Send the HTTP POST request with the comment data and authentication headers
      final response = await http.post(_dislikeCommentUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {"comment": comment});

      // If the response status code is 200 OK, parse the JSON response body and return it
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // If there is an error with the HTTP request, throw an exception with the error message
      throw Exception("Error during post: $e");
    }
  }

// This function is used to unlike a comment on a post.
  static Future<Map<String, dynamic>> unlikeComment(
      final String comment) async {
    try {
      final response = await http.post(_unlikeCommentUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {"comment": comment});

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // Catch any exceptions that occur during the post and throw a new exception with the error message.
      throw Exception("Error during post: $e");
    }
  }

// This function is used to undislike a comment on a post.
  static Future<Map<String, dynamic>> undislikeComment(
      final String comment) async {
    try {
      final response = await http.post(_undislikeCommentUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {"comment": comment});

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // Catch any exceptions that occur during the post and throw a new exception with the error message.
      throw Exception("Error during post: $e");
    }
  }

// This function is used to delete a comment on a post.
  static Future<Map<String, dynamic>> delComment(final String comment) async {
    try {
      final response = await http.delete(_commentUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {"comment": comment});
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // Catch any exceptions that occur during the post and throw a new exception with the error message.
      throw Exception("Error during post: $e");
    }
  }

  static Future<Map<String, dynamic>> postComment(
      final String post, final String content) async {
    // The method takes two parameters: the post ID and the content of the comment to be posted.

    try {
      // The code tries to make an HTTP POST request to the given URL with the given headers and body parameters.
      final response = await http.post(_commentUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {"post": post, "content": content});

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // If there is any other error during the HTTP request, it throws an Exception with a message containing the error.
      throw Exception("Error during post: $e");
    }
  }

  static Future<Map<String, dynamic>> savePost(final String post) async {
    // The method takes one parameter: the post ID to be saved.

    try {
      // The code tries to make an HTTP POST request to the given URL with the given headers and body parameters.
      final response = await http.post(_savePostUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {
            "post": post,
          });
      await NetworkManager.instance
          .deleteLocalData(name: "posts", type: CacheTypes.list);
      await NetworkManager.instance
          .deleteLocalData(name: "saved-posts", type: CacheTypes.list);

      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // If there is any other error during the HTTP request, it throws an Exception with a message containing the error.
      throw Exception("Error during post: $e");
    }
  }

  static Future<Map<String, dynamic>> unsavePost(final String post) async {
    // function to unsave a post

    try {
      final response = await http.post(_unsavePostUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {
            "post": post, // include the post ID in the request body
          });
      await NetworkManager.instance
          .deleteLocalData(name: "posts", type: CacheTypes.list);
      await NetworkManager.instance
          .deleteLocalData(name: "saved-posts", type: CacheTypes.list);
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // handle any exceptions that occur during the HTTP request
      throw Exception(
          "Error during post: $e"); // throw an exception with the error message
    }
  }

  static Future<Map<String, dynamic>> likePost(final String post) async {
    // function to like a post

    try {
      final response = await http.post(_likePostUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {
            "post": post, // include the post ID in the request body
          });
      await NetworkManager.instance
          .deleteLocalData(name: "posts", type: CacheTypes.list);
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // handle any exceptions that occur during the HTTP request
      throw Exception(
          "Error during post: $e"); // throw an exception with the error message
    }
  }

  static Future<Map<String, dynamic>> unlikePost(final String post) async {
    // function to unlike a post

    try {
      final response = await http.post(_unlikePostUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {
            "post": post, // include the post ID in the request body
          });
      await NetworkManager.instance
          .deleteLocalData(name: "posts", type: CacheTypes.list);
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // handle any exceptions that occur during the HTTP request
      throw Exception(
          "Error during post: $e"); // throw an exception with the error message
    }
  }

  static Future<Map<String, dynamic>> getUser(final String id) async {
    // Specifying that the function returns a future object of a Map object with key-value pairs of type string-dynamic

    try {
      // Using a try-catch block to handle errors
      final String? localData = await NetworkManager.instance
          .getLocalData(name: id, type: CacheTypes.user);

      if (localData != null) {
        final Map<String, dynamic> cachedUser =
            TypeCasts.stringToJson(localData);
        return cachedUser;
      }
      final response = await http.get(
        // Creating a variable 'response' and making a post request to the specified URL
        _userUrl,
        headers: {
          "Content-Type":
              "application/x-www-form-urlencoded", // Specifying the headers for the request
          "Authorization":
              "Bearer ${await storage.getToken()}", // Including the authorization token
          "id": id,
        },
      );
      final Map<String, dynamic> data =
          ResponseHandler.handleResponse(response);
      if (data["avatar_id"] == null) {
        data["avatar_id"] = "default";
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

  static Future<List<Map<String, dynamic>>> getUserPosts(
      final String userId, final int page) async {
    // Specifying that the function returns a future object of a Map object with key-value pairs of type string-dynamic

    try {
      final String? localData = page == 0
          ? (await NetworkManager.instance
              .getLocalData(name: "user-posts-$userId", type: CacheTypes.list))
          : null;

      if (localData != null) {
        final List<Map<String, dynamic>> cachedPosts =
            TypeCasts.stringArrayToJsonArray(localData);
        return cachedPosts;
      }
      // Using a try-catch block to handle errors
      final response = await http.get(
        // Creating a variable 'response' and making a post request to the specified URL
        _userPostsUrl,
        headers: {
          "Content-Type":
              "application/x-www-form-urlencoded", // Specifying the headers for the request
          "Authorization":
              "Bearer ${await storage.getToken()}", // Including the authorization token
          "page": page.toString(),
          "user": userId
        },
      );
      final List<Map<String, dynamic>> data =
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

  static Future<List<Map<String, dynamic>>> getUserFollowing(
      final int page, final Map<String, dynamic>? user) async {
    // Specifying that the function returns a future object of a Map object with key-value pairs of type string-dynamic

    try {
      final String userId = user?["user_id"] ?? await storage.getId();
      final String? localData = page == 0
          ? (await NetworkManager.instance.getLocalData(
              name: "user-following-$userId", type: CacheTypes.list))
          : null;

      if (localData != null) {
        final List<Map<String, dynamic>> cachedUsers =
            TypeCasts.stringArrayToJsonArray(localData);
        return cachedUsers;
      }
      // Using a try-catch block to handle errors
      final Map<String, String> headers = {
        "Content-Type":
            "application/x-www-form-urlencoded", // Specifying the headers for the request
        "Authorization":
            "Bearer ${await storage.getToken()}", // Including the authorization token
        "page": page.toString(),
      };
      if (user?["user_id"] != null) {
        headers["user"] = user!["user_id"];
      }
      final response = await http.get(
          // Creating a variable 'response' and making a post request to the specified URL
          _userFollowing,
          headers: headers);
      final List<Map<String, dynamic>> data =
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

  static Future<List<Map<String, dynamic>>> getUserFollowers(
      final int page, final Map<String, dynamic>? user) async {
    // Specifying that the function returns a future object of a Map object with key-value pairs of type string-dynamic
    final String userId = user?["user_id"] ?? await storage.getId();

    final String? localData = await NetworkManager.instance
        .getLocalData(name: "user-followers-$userId", type: CacheTypes.list);

    if (localData != null) {
      final List<Map<String, dynamic>> cachedUsers =
          TypeCasts.stringArrayToJsonArray(localData);
      return cachedUsers;
    }

    try {
      // Using a try-catch block to handle errors
      final Map<String, String> headers = {
        "Content-Type":
            "application/x-www-form-urlencoded", // Specifying the headers for the request
        "Authorization":
            "Bearer ${await storage.getToken()}", // Including the authorization token
        "page": page.toString(),
      };
      if (user?["user_id"] != null) {
        headers["user"] = user!["user_id"];
      }
      final response = await http.get(
          // Creating a variable 'response' and making a post request to the specified URL
          _userFollowers,
          headers: headers);
      final List<Map<String, dynamic>> data =
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

  static Future<List<Map<String, dynamic>>> getUserFriends(
      final int page, final Map<String, dynamic>? user) async {
    // Specifying that the function returns a future object of a Map object with key-value pairs of type string-dynamic
    final String userId = user?["user_id"] ?? await storage.getId();

    final String? localData = page == 0
        ? (await NetworkManager.instance
            .getLocalData(name: "user-friends-$userId", type: CacheTypes.list))
        : null;

    if (localData != null) {
      final List<Map<String, dynamic>> cachedUsers =
          TypeCasts.stringArrayToJsonArray(localData);
      return cachedUsers;
    }

    try {
      // Using a try-catch block to handle errors
      final Map<String, String> headers = {
        "Content-Type":
            "application/x-www-form-urlencoded", // Specifying the headers for the request
        "Authorization":
            "Bearer ${await storage.getToken()}", // Including the authorization token
        "page": page.toString(),
      };
      if (user?["user_id"] != null) {
        headers["user"] = user!["user_id"];
      }
      final response = await http.get(
          // Creating a variable 'response' and making a post request to the specified URL
          _userFriends,
          headers: headers);
      final List<Map<String, dynamic>> data =
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
  static Future<List<Map<String, dynamic>>> searchUsers(
      final String query) async {
    // Define the URL for the HTTP request

    try {
      // Make a POST request to the specified URL with headers and parameters
      final response = await http.get(
        _searchUsersUrl,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Bearer ${await storage.getToken()}",
          "query": query
        },
      );

      // If the response status code is 200 OK, parse and return the response body as a Map
      return handleResponse(response, Resp.listResponse);
    } catch (e) {
      // If there's an error, throw an exception with the error message
      throw Exception("Error during post: $e");
    }
  }

  static Future<Map<String, dynamic>> setEmail(final String email) async {
    // Specifying that the function returns a future object of a Map object with key-value pairs of type string-dynamic
    if (!EmailValidator.validate(email)) {
      throw Exception("Invalid Email");
    }

    try {
      // Using a try-catch block to handle errors
      final response = await http.post(
          // Creating a variable 'response' and making a post request to the specified URL
          _userEmailUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {
            "email": email,
          });
      if (response.statusCode == 200) {
        unawaited(NetworkManager.instance.deleteLocalData(
            name: "user-email-verified", type: CacheTypes.verified));
      }
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // Handling the error
      throw Exception(
          "Error during post: $e"); // Throwing an exception with an error message
    }
  }

  static Future<Map<String, dynamic>> setDescription(final String desc) async {
    // Specifying that the function returns a future object of a Map object with key-value pairs of type string-dynamic
    if (desc.length > 250) {
      throw Exception("Invalid Description");
    }

    try {
      // Using a try-catch block to handle errors
      final response = await http.post(
          // Creating a variable 'response' and making a post request to the specified URL
          _userDescriptionUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {
            "description": desc,
          });
      await NetworkManager.instance
          .deleteLocalData(name: "0", type: CacheTypes.user);
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // Handling the error
      throw Exception(
          "Error during post: $e"); // Throwing an exception with an error message
    }
  }

  static Future<Map<String, dynamic>> setAvatar(final String avatar) async {
    // Specifying that the function returns a future object of a Map object with key-value pairs of type string-dynamic

    try {
      // Using a try-catch block to handle errors
      final response = await http.post(
          // Creating a variable 'response' and making a post request to the specified URL
          _userAvatarUrl,
          headers: await Config.getDefaultHeadersAuth,
          body: {
            "avatar": avatar,
          });
      await NetworkManager.instance
          .deleteLocalData(name: "0", type: CacheTypes.user);
      return handleResponse(response, Resp.stringResponse);
    } catch (e) {
      // Handling the error
      throw Exception(
          "Error during post: $e"); // Throwing an exception with an error message
    }
  }

// Get a list of saved posts
  static Future<List<Map<String, dynamic>>> getSavedPosts(
      final int pageKey) async {
    if (pageKey == 0) {
      final String? localData = pageKey == 0
          ? (await NetworkManager.instance
              .getLocalData(name: "saved-posts", type: CacheTypes.list))
          : null;

      if (localData != null) {
        final List<Map<String, dynamic>> cachedPosts =
            TypeCasts.stringArrayToJsonArray(localData);
        return cachedPosts;
      }
      commonLogger
        ..d(localData)
        ..d("localData");
    }
    // Define the URL for the HTTP request

    try {
      // Make a POST request to the specified URL with headers and parameters
      final response = await http.get(
        _savedPostsUrl,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Bearer ${await storage.getToken()}",
          "page": pageKey.toString()
        },
      );
      final List<Map<String, dynamic>> data =
          ResponseHandler.handleListResponse(response);
      if (pageKey == 0) {
        unawaited(NetworkManager.instance
            .saveData(name: "saved-posts", type: CacheTypes.list, data: data));
      }
      // If the response status code is 200 OK, parse and return the response body as a Map
      return data;
    } catch (e) {
      // If there's an error, throw an exception with the error message
      throw Exception("Error during saved posts: $e");
    }
  }
}
