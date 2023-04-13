import 'token.dart';

// Import necessary dependencies and files
import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:convert';

// Export login and signup functions from auth.dart
export 'package:skating_app/api/social.dart'
    show
        postPost,
        getPost,
        getPosts,
        delPost,
        getComments,
        getComment,
        likeComment,
        dislikeComment,
        unlikeComment,
        undislikeComment,
        delComment,
        postComment,
        savePost,
        unsavePost,
        likePost,
        unlikePost;

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
Future<Object> postPost(String description, String image) async {
  // Define the URL endpoint for login
  var url = Uri.parse('${Config.uri}/post/post');

  try {
    // Make a POST request to the login endpoint with the user's credentials
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${storage.getToken()}'
      },
      body: {'description': description, 'image': image},
    );

    // If the response is successful, extract the token from the response body and return it
    if (response.statusCode == 200) {
      Map<String, dynamic> y = json.decode(response.body);
      return y;
    } else {
      // If the response is not successful, throw an exception with the reason phrase
      throw Exception("Post Unsuccessful: ${response.reasonPhrase}");
    }
  } catch (e) {
    // If there is an error during login, throw an exception with the error message
    throw Exception("Error during post: $e");
  }
}

// Get a single post by its ID
Future<Object> getPost(String post) async {
  // Define the URL for the HTTP request
  var url = Uri.parse('${Config.uri}/post/post');

  try {
    // Make a GET request to the specified URL with headers and parameters
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${storage.getToken()}',
        'post': post
      },
    );

    // If the response status code is 200 OK, parse and return the response body as a Map
    if (response.statusCode == 200) {
      Map<String, dynamic> y = json.decode(response.body);
      return y;
    } else {
      // Otherwise, throw an exception with the reason phrase of the response
      throw Exception("Post Unsuccessful: ${response.reasonPhrase}");
    }
  } catch (e) {
    // If there's an error, throw an exception with the error message
    throw Exception("Error during post: $e");
  }
}

// Get a list of posts, excluding those with IDs in the "seen" list
Future<List<Object>> getPosts(List<String> seen) async {
  String seenPosts = seen.toString();
  // Define the URL for the HTTP request
  var url = Uri.parse('${Config.uri}/post/posts');

  try {
    // Make a POST request to the specified URL with headers and parameters
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}'
      },
      body: {'seen': seenPosts},
    );

    // If the response status code is 200 OK, parse and return the response body as a Map
    if (response.statusCode == 200) {
      List<Object> y = json.decode(response.body).cast<Object>();
      return y;
    } else {
      // Otherwise, throw an exception with the reason phrase of the response
      throw Exception("Post Unsuccessful: ${response.reasonPhrase}");
    }
  } catch (e) {
    // If there's an error, throw an exception with the error message
    throw Exception("Error during post: $e");
  }
}

// Delete a single post by its ID
Future<Object> delPost(String post) async {
  // Define the URL for the HTTP request
  var url = Uri.parse('${Config.uri}/post/post');

  try {
    // Make a DELETE request to the specified URL with headers and parameters
    var response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${storage.getToken()}'
      },
      body: {'post': post},
    );

    // If the response status code is 200 OK, parse and return the response body as a Map
    if (response.statusCode == 200) {
      Map<String, dynamic> y = json.decode(response.body);
      return y;
    } else {
      // Otherwise, throw an exception with the reason phrase of the response
      throw Exception("Post Unsuccessful: ${response.reasonPhrase}");
    }
  } catch (e) {
    // If there's an error, throw an exception with the error message
    throw Exception("Error during post: $e");
  }
}

// This function retrieves comments for a given post and page number
// It returns a Future<Object> which resolves to a Map<String, dynamic> representing the comments
Future<Object> getComments(String post, int page) async {
  var url = Uri.parse('${Config.uri}/post/comments');

  try {
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization':
            'Bearer ${storage.getToken()}', // Include authentication token in the header
        'post': post, // Specify the post ID to retrieve comments for
        'page':
            page.toString(), // Specify the page number of comments to retrieve
      },
    );

    if (response.statusCode == 200) {
      // Check if the response status code is successful
      Map<String, dynamic> y = json.decode(response
          .body); // Decode the response body and return it as a Map<String, dynamic>
      return y;
    } else {
      throw Exception(
          "Post Unsuccessful: ${response.reasonPhrase}"); // Throw an exception if the response status code is not successful
    }
  } catch (e) {
    throw Exception(
        "Error during post: $e"); // Throw an exception if there is an error during the request
  }
}

// This function retrieves a single comment for a given comment ID
// It returns a Future<Object> which resolves to a Map<String, dynamic> representing the comment
Future<Object> getComment(String comment) async {
  var url = Uri.parse('${Config.uri}/post/comment');

  try {
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization':
            'Bearer ${storage.getToken()}', // Include authentication token in the header
        'comment': comment // Specify the comment ID to retrieve
      },
    );

    if (response.statusCode == 200) {
      // Check if the response status code is successful
      Map<String, dynamic> y = json.decode(response
          .body); // Decode the response body and return it as a Map<String, dynamic>
      return y;
    } else {
      throw Exception(
          "Post Unsuccessful: ${response.reasonPhrase}"); // Throw an exception if the response status code is not successful
    }
  } catch (e) {
    throw Exception(
        "Error during post: $e"); // Throw an exception if there is an error during the request
  }
}

// Function to like a comment using HTTP POST request
Future<Object> likeComment(String comment) async {
  // Define the URL for the API endpoint
  var url = Uri.parse('${Config.uri}/post/like_comment');

  try {
    // Send the HTTP POST request with the comment data and authentication headers
    var response = await http.post(url, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer ${storage.getToken()}',
    }, body: {
      'comment': comment
    });

    // If the response status code is 200 OK, parse the JSON response body and return it
    if (response.statusCode == 200) {
      Map<String, dynamic> y = json.decode(response.body);
      return y;
    } else {
      // If the response status code is not 200, throw an exception with the error message
      throw Exception("Post Unsuccessful: ${response.reasonPhrase}");
    }
  } catch (e) {
    // If there is an error with the HTTP request, throw an exception with the error message
    throw Exception("Error during post: $e");
  }
}

// Function to dislike a comment using HTTP POST request
Future<Object> dislikeComment(String comment) async {
  // Define the URL for the API endpoint
  var url = Uri.parse('${Config.uri}/post/dislike_comment');

  try {
    // Send the HTTP POST request with the comment data and authentication headers
    var response = await http.post(url, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer ${storage.getToken()}',
    }, body: {
      'comment': comment
    });

    // If the response status code is 200 OK, parse the JSON response body and return it
    if (response.statusCode == 200) {
      Map<String, dynamic> y = json.decode(response.body);
      return y;
    } else {
      // If the response status code is not 200, throw an exception with the error message
      throw Exception("Post Unsuccessful: ${response.reasonPhrase}");
    }
  } catch (e) {
    // If there is an error with the HTTP request, throw an exception with the error message
    throw Exception("Error during post: $e");
  }
}

// This function is used to unlike a comment on a post.
Future<Object> unlikeComment(String comment) async {
  var url = Uri.parse('${Config.uri}/post/unlike_comment');

  try {
    var response = await http.post(url, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer ${storage.getToken()}',
    }, body: {
      'comment': comment
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> y = json.decode(response.body);
      return y;
    } else {
      // Throw an exception if the response is not successful.
      throw Exception("Post Unsuccessful: ${response.reasonPhrase}");
    }
  } catch (e) {
    // Catch any exceptions that occur during the post and throw a new exception with the error message.
    throw Exception("Error during post: $e");
  }
}

// This function is used to undislike a comment on a post.
Future<Object> undislikeComment(String comment) async {
  var url = Uri.parse('${Config.uri}/post/undislike_comment');

  try {
    var response = await http.post(url, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer ${storage.getToken()}',
    }, body: {
      'comment': comment
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> y = json.decode(response.body);
      return y;
    } else {
      // Throw an exception if the response is not successful.
      throw Exception("Post Unsuccessful: ${response.reasonPhrase}");
    }
  } catch (e) {
    // Catch any exceptions that occur during the post and throw a new exception with the error message.
    throw Exception("Error during post: $e");
  }
}

// This function is used to delete a comment on a post.
Future<Object> delComment(String comment) async {
  var url = Uri.parse('${Config.uri}/post/comment');

  try {
    var response = await http.delete(url, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer ${storage.getToken()}',
    }, body: {
      'comment': comment
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> y = json.decode(response.body);
      return y;
    } else {
      // Throw an exception if the response is not successful.
      throw Exception("Post Unsuccessful: ${response.reasonPhrase}");
    }
  } catch (e) {
    // Catch any exceptions that occur during the post and throw a new exception with the error message.
    throw Exception("Error during post: $e");
  }
}

Future<Object> postComment(String post, String content) async {
  // The method takes two parameters: the post ID and the content of the comment to be posted.
  var url = Uri.parse('${Config.uri}/post/comment');

  try {
    // The code tries to make an HTTP POST request to the given URL with the given headers and body parameters.
    var response = await http.post(url, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer ${storage.getToken()}',
    }, body: {
      'post': post,
      'content': content
    });

    // If the HTTP response status code is 200, it returns the response body as a Map<String, dynamic>.
    if (response.statusCode == 200) {
      Map<String, dynamic> y = json.decode(response.body);
      return y;
    } else {
      // Otherwise, it throws an Exception with a message containing the HTTP response reason phrase.
      throw Exception("Post Unsuccessful: ${response.reasonPhrase}");
    }
  } catch (e) {
    // If there is any other error during the HTTP request, it throws an Exception with a message containing the error.
    throw Exception("Error during post: $e");
  }
}

Future<Object> savePost(String post) async {
  // The method takes one parameter: the post ID to be saved.
  var url = Uri.parse('${Config.uri}/post/save');

  try {
    // The code tries to make an HTTP POST request to the given URL with the given headers and body parameters.
    var response = await http.post(url, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer ${storage.getToken()}',
    }, body: {
      'post': post,
    });

    // If the HTTP response status code is 200, it returns the response body as a Map<String, dynamic>.
    if (response.statusCode == 200) {
      Map<String, dynamic> y = json.decode(response.body);
      return y;
    } else {
      // Otherwise, it throws an Exception with a message containing the HTTP response reason phrase.
      throw Exception("Post Unsuccessful: ${response.reasonPhrase}");
    }
  } catch (e) {
    // If there is any other error during the HTTP request, it throws an Exception with a message containing the error.
    throw Exception("Error during post: $e");
  }
}

Future<Object> unsavePost(String post) async {
  // function to unsave a post
  var url = Uri.parse('${Config.uri}/post/unsave'); // endpoint URL

  try {
    var response = await http.post(url, headers: {
      // make a HTTP POST request with headers
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization':
          'Bearer ${storage.getToken()}', // include authorization token in headers
    }, body: {
      'post': post, // include the post ID in the request body
    });

    if (response.statusCode == 200) {
      // if the response is successful
      Map<String, dynamic> y =
          json.decode(response.body); // parse the response body
      return y; // return the parsed response
    } else {
      throw Exception(
          "Post Unsuccessful: ${response.reasonPhrase}"); // throw an exception if the response is not successful
    }
  } catch (e) {
    // handle any exceptions that occur during the HTTP request
    throw Exception(
        "Error during post: $e"); // throw an exception with the error message
  }
}

Future<Object> likePost(String post) async {
  // function to like a post
  var url = Uri.parse('${Config.uri}/post/like'); // endpoint URL

  try {
    var response = await http.post(url, headers: {
      // make a HTTP POST request with headers
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization':
          'Bearer ${storage.getToken()}', // include authorization token in headers
    }, body: {
      'post': post, // include the post ID in the request body
    });

    if (response.statusCode == 200) {
      // if the response is successful
      Map<String, dynamic> y =
          json.decode(response.body); // parse the response body
      return y; // return the parsed response
    } else {
      throw Exception(
          "Post Unsuccessful: ${response.reasonPhrase}"); // throw an exception if the response is not successful
    }
  } catch (e) {
    // handle any exceptions that occur during the HTTP request
    throw Exception(
        "Error during post: $e"); // throw an exception with the error message
  }
}

Future<Object> unlikePost(String post) async {
  // function to unlike a post
  var url = Uri.parse('${Config.uri}/post/unlike'); // endpoint URL

  try {
    var response = await http.post(url, headers: {
      // make a HTTP POST request with headers
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization':
          'Bearer ${storage.getToken()}', // include authorization token in headers
    }, body: {
      'post': post, // include the post ID in the request body
    });

    if (response.statusCode == 200) {
      // if the response is successful
      Map<String, dynamic> y =
          json.decode(response.body); // parse the response body
      return y; // return the parsed response
    } else {
      throw Exception(
          "Post Unsuccessful: ${response.reasonPhrase}"); // throw an exception if the response is not successful
    }
  } catch (e) {
    // handle any exceptions that occur during the HTTP request
    throw Exception(
        "Error during post: $e"); // throw an exception with the error message
  }
}
