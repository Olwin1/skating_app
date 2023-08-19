// Importing the required dependencies
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart';
import 'package:mime/mime.dart';

import '../common_logger.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:http_parser/http_parser.dart';

// Exporting functions from the messages.dart file
export 'package:patinka/api/image.dart';

Future<Uint8List> compressImage(Uint8List image) async {
  var result = await FlutterImageCompress.compressWithList(
    image,
    minHeight: 1080,
    minWidth: 1080,
    quality: 96,
  );
  commonLogger.v("Image Successfully Compressed: ${image.length}");

  return result;
}

// This function takes in a byte array 'image', and uploads it to a server using HTTP POST request.
// It also adds an authorization header with a bearer token obtained from a storage object.
// The server endpoint for the upload is obtained from a Config object.
Future<StreamedResponse?> uploadFile(Uint8List image) async {
  try {
    Uint8List uploadImage = await compressImage(image);

    // Parse the server endpoint URL from Config object
    var postUri = Uri.parse("${Config.uri}/upload");

    // Create a new HTTP POST request object with the server endpoint URL
    var request = http.MultipartRequest("POST", postUri);

    // Determine the MIME type of the image using the lookupMimeType() function from the mime_type package
    var mime = lookupMimeType('', headerBytes: uploadImage);

    // Split the MIME type string into two parts using the '/' delimiter
    var extension = mime!.split("/");

    // Print the file extension to the console for debugging purposes
    commonLogger.d("File extension is: $extension");

    // Add an authorization header to the HTTP request using a bearer token obtained from a storage object
    request.headers['Authorization'] = 'Bearer ${await storage.getToken()}';

    // Add the image data as a multipart/form-data file attachment to the HTTP request
    request.files.add(http.MultipartFile.fromBytes('file', uploadImage,
        contentType: MediaType(extension[0], extension[1]), filename: "file"));

    // Send the HTTP request asynchronously and handle the response in a callback function
    StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      // If the server returns a 200 status code, print a success message to the console
      commonLogger.v("Response: 200 Image Upload");

      return response;
    } else {
      // Otherwise, print an error message to the console
      commonLogger.e("Response: Non 200 - $response");

      return null;
    }
  } catch (e) {
    // If an error occurs during the file upload process, print an error message to the console
    commonLogger.e("An Error Occurred during file upload");
    return null;
  }
}
