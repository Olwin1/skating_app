import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:skating_app/api/image.dart';
import 'package:skating_app/api/social.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Define a widget for sending a post with an image
class SendPost extends StatefulWidget {
  const SendPost({Key? key, required this.image}) : super(key: key);
  final Uint8List image;

  @override
  State<SendPost> createState() => _SendPost(); // Create state for widget
}

// Define the state for sending a post with an image
class _SendPost extends State<SendPost> {
  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  // Override the existing build method to create the widget UI
  @override
  Widget build(BuildContext context) {
    // Define a function to send the post information
    Future<String?> sendImage() async {
      try {
        // Upload the image file
        StreamedResponse? response = await uploadFile(widget.image);
        String? id = await response?.stream.bytesToString();
        if (id != null) {
          return id.substring(1, id.length - 1);
          //Navigator.of(context).pop();
        }
        // Close the current screen and go back to the previous screen
      } catch (e) {
        // If there is an error, print the error message to the console
        print("An Error Occurred: $e");
      }
      return null;
    }

// Define a function named "sendInfo"
    void sendInfo() {
      try {
        // Call the "sendImage" function and wait for it to complete
        sendImage().then((value) => {
              // When "sendImage" completes successfully, call "postPost"
              // with the text from "descriptionController" and the returned value
              postPost(descriptionController.text, value!)
                  // Wait for "postPost" to complete successfully
                  .then((value) =>
                      // When "postPost" completes successfully, close the current screen
                      Navigator.of(context).pop())
            });
      } catch (e) {
        print("Error creating post");
      }
    }

    // Return the scaffold with the app bar and body
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Disables automatic resizing of the screen when the keyboard is opened.
      appBar: AppBar(
        // Top bar of the page.
        leadingWidth: 48, // Adjusts the width of the leading widget.
        centerTitle: false, // Aligns the title to the left.
        title: Title(
          title: AppLocalizations.of(context)!
              .createPost, // Sets the title of the app bar.
          color: const Color(0xFFDDDDDD), // Sets the color of the title.
          child: Text(AppLocalizations.of(context)!
              .createPost), // The actual text of the title.
        ),
        actions: [
          TextButton(
              onPressed: () => sendInfo(),
              child: Text(
                AppLocalizations.of(context)!.send,
                style: const TextStyle(color: Color(0xFFDDDDDD)),
              )) // A button to send the post.
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(48), // Adds padding to the entire body.
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Aligns the children to the left.
          children: [
            Container(
              color: const Color(
                  0xffcecece), // Sets the background color of the container.
              child: Column(
                children: [
                  Text(AppLocalizations.of(context)!
                      .postDescription), // The label for the text field.
                  TextField(
                    controller:
                        descriptionController, // The controller for the text field.
                    autofocus:
                        false, // The text field doesn't automatically get focus when the page is opened.
                  ),
                ],
              ),
            ),
            Image.memory(widget.image)
          ],
        ),
      ),
    );
  }
}
