// Importing the required dependencies
import 'token.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:convert';

// Exporting functions from the messages.dart file
export 'package:patinka/api/messages.dart'
    show
        postChannel,
        postMessage,
        getMessage,
        getMessages,
        getChannels,
        getChannel,
        getUserId;

// Creating an instance of SecureStorage class
SecureStorage storage = SecureStorage();

// Function to create a new channel
Future<Object> postChannel(List<String> participants) async {
  var url = Uri.parse('${Config.uri}/message/channel');

  try {
    // Making a POST request to the specified URL with the required headers and body
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}'
      },
      body: {'participants': participants},
    );

    // If the response status code is 200, return the response body
    if (response.statusCode == 200) {
      Map<String, dynamic> y = json.decode(response.body);
      return y;
    } else {
      // If the response status code is not 200, throw an exception with the reason phrase
      throw Exception(
          "Channel Creation Unsuccessful: ${response.reasonPhrase}");
    }
  } catch (e) {
    // If there is any error, throw an exception with the error message
    throw Exception("Error during post: $e");
  }
}

Future<String?> getUserId() async {
  return await storage.getId();
}

// Function to send a message to a channel
Future<Object> postMessage(String channel, String content, String? img) async {
  var url = Uri.parse('${Config.uri}/message/message');

  try {
    // Making a POST request to the specified URL with the required headers and body
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ${await storage.getToken()}'
      },
      body: {
        'channel': channel,
        'content': content,
        if (img != null) 'img': img
      },
    );

    // If the response status code is 200, return the response body
    if (response.statusCode == 200) {
      Map<String, dynamic> y = json.decode(response.body);
      return y;
    } else {
      // If the response status code is not 200, throw an exception with the reason phrase
      throw Exception(
          "Message Creation Unsuccessful: ${response.reasonPhrase}");
    }
  } catch (e) {
    // If there is any error, throw an exception with the error message
    throw Exception("Error during post: $e");
  }
}

Future<Object> getMessage(
    String message, String messageNumber, String channel) async {
  var url = Uri.parse('${Config.uri}/message/message');

  // Make an HTTP GET request to the specified URL with headers and parameters
  try {
    var response = await http.get(url, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer ${await storage.getToken()}',
      'message': message,
      'message_number': messageNumber,
      'channel': channel,
    });

    // If the response status code is 200 (OK), decode the response body as a JSON object and return it
    if (response.statusCode == 200) {
      Map<String, dynamic> y = json.decode(response.body);
      return y;
    } else {
      // If the response status code is not 200, throw an exception with the reason phrase
      throw Exception("Get Unsuccessful: ${response.reasonPhrase}");
    }
  } catch (e) {
    // If an error occurs during the HTTP request, throw an exception with the error message
    throw Exception("Error during post: $e");
  }
}

// This is a function that takes in two arguments, `page` and `channel`,
// and returns a Future that resolves to a Map of String to dynamic values.

Future<List<Object>> getMessages(int page, String channel) async {
  // `url` is a Uri object that is constructed with a string
  // that includes the base URI and the endpoint path.
  var url = Uri.parse('${Config.uri}/message/messages');

  try {
    // `response` is an HTTP response that is returned from an asynchronous
    // HTTP GET request that is made using the `http` package.
    // It includes headers and body.
    var response = await http.get(url, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer ${await storage.getToken()}',
      'page': page.toString(),
      'channel': channel,
    });

    // If the HTTP response status code is 200,
    // then the response body is decoded from JSON
    // and returned as a Map of String to dynamic values.
    if (response.statusCode == 200) {
      List<Object> y = json.decode(response.body).cast<Object>();
      return y;
    } else {
      // If the HTTP response status code is not 200,
      // then an exception is thrown with the response reason phrase.
      throw Exception("Get Unsuccessful: ${response.reasonPhrase}");
    }
  } catch (e) {
    // If an error occurs during the HTTP GET request,
    // then an exception is thrown with the error message.
    throw Exception("Error during post: $e");
  }
}

// This function doth take a single argument, a string called 'page'
// It returns a Future object, the value of which shall be determined in due course
Future<List<Map<String, dynamic>>> getChannels(int page) async {
  // Declare a new variable called 'url' and assign it a new Uri object which contains the base URL of the API endpoint
  var url = Uri.parse('${Config.uri}/message/channels');

  try {
    // Issue an HTTP GET request to the aforementioned URL, with some headers added for good measure
    var response = await http.get(url, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer ${await storage.getToken()}',
      'page': page.toString(),
    });

    // If the response status code is 200, then decode the response body into a new map object called 'y' and return it
    if (response.statusCode == 200) {
      List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
        json
            .decode(response.body)
            .map((model) => Map<String, dynamic>.from(model)),
      );
      return data;
    } else {
      // If the response status code is anything other than 200, then throw an Exception containing the reason phrase of the response
      throw Exception("Get Unsuccessful: ${response.reasonPhrase}");
    }
  } catch (e) {
    // If an error is thrown within the try-catch block, then throw a different Exception which contains a message that describes the error that was encountered
    throw Exception("Error during post: $e");
  }
}

Future<Object> getChannel(String channel) async {
  // Construct URL for the API endpoint
  var url = Uri.parse('${Config.uri}/message/channel');

  try {
    // Send a GET request to the API endpoint with the channel parameter
    var response = await http.get(url, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer ${await storage.getToken()}',
      'channel': channel,
    });

    if (response.statusCode == 200) {
      // Parse the JSON response into a Map object and return it
      Map<String, dynamic> y = json.decode(response.body);
      return y;
    } else {
      // Throw an exception if the API call was unsuccessful
      throw Exception("Get Unsuccessful: ${response.reasonPhrase}");
    }
  } catch (e) {
    // Catch any errors that occur during the API call and throw an exception
    throw Exception("Error during API call: $e");
  }
}
