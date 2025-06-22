// Importing the required dependencies
import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_image_compress/flutter_image_compress.dart";
import "package:http/http.dart" as http;
import "package:http/http.dart";
import "package:http_parser/http_parser.dart";
import "package:mime/mime.dart";
import "package:patinka/api/config/config.dart";
import "package:patinka/api/image/image_manager_stub.dart"
    if (dart.library.io) "package:patinka/api/image/image_manager_io.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/misc/notifications/error_notification.dart"
    as error_notification;
import "package:patinka/services/navigation_service.dart";

// Exporting functions from the messages.dart file
export "package:patinka/api/image/image.dart";

Future<Uint8List> compressImage(final Uint8List image) async {
  final result = await FlutterImageCompress.compressWithList(
    image,
    minHeight: 1080,
    minWidth: 1080,
    quality: 96,
  );
  commonLogger.t("Image Successfully Compressed: ${image.length}");

  return result;
}

// This function takes in a byte array 'image', and uploads it to a server using HTTP POST request.
// It also adds an authorization header with a bearer token obtained from a storage object.
// The server endpoint for the upload is obtained from a Config object.
Future<StreamedResponse?> uploadFile(final Uint8List image) async {
  try {
    final Uint8List uploadImage = await compressImage(image);

    // Parse the server endpoint URL from Config object
    final postUri = Uri.parse("${Config.uri}/upload");

    // Create a new HTTP POST request object with the server endpoint URL
    final request = http.MultipartRequest("POST", postUri);

    // Determine the MIME type of the image using the lookupMimeType() function from the mime_type package
    final mime = lookupMimeType("", headerBytes: uploadImage);

    // Split the MIME type string into two parts using the '/' delimiter
    final extension = mime!.split("/");

    // Print the file extension to the console for debugging purposes
    commonLogger.d("File extension is: $extension");

    // Add an authorization header to the HTTP request using a bearer token obtained from a storage object
    request.headers["Authorization"] = "Bearer ${await storage.getToken()}";

    // Add the image data as a multipart/form-data file attachment to the HTTP request
    request.files.add(http.MultipartFile.fromBytes("file", uploadImage,
        contentType: MediaType(extension[0], extension[1]), filename: "file"));

    // Send the HTTP request asynchronously and handle the response in a callback function
    final StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      // If the server returns a 200 status code, print a success message to the console
      commonLogger.t("Response: 200 Image Upload");

      return response;
    } else {
      // Notification handler for failure
      final GlobalKey<NavigatorState> navigatorState =
          NavigationService.currentNavigatorKey;
      if (navigatorState.currentContext != null) {
        // If a build context could be found then show a failure message to the user
        error_notification.showNotification(
            navigatorState.currentContext!, "Image Failed To Upload");
      }
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

Future<bool> downloadBackgroundImage(
    final double physicalPixelWidth, final double physicalPixelHeight) async {
  try {
    final String url = "${Config.uri}/image/background/graffiti.png";

    final response = await http.get(Uri.parse(url), headers: {
      "width": physicalPixelWidth.toString(),
      "height": physicalPixelHeight.toString()
    });

    return await saveBackgroundFile(response.bodyBytes, url);
  } catch (e) {
    commonLogger.e("Error downloading background image: $e");
    return false;
  }
}
