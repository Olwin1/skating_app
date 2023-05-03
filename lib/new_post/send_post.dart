import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:skating_app/api/image.dart';

// Define a widget for sending a post with an image
class SendPost extends StatefulWidget {
  const SendPost({Key? key, required this.image}) : super(key: key);
  final Uint8List image;

  @override
  State<SendPost> createState() => _SendPost(); // Create state for widget
}

// Define the state for sending a post with an image
class _SendPost extends State<SendPost> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  // Override the existing build method to create the widget UI
  @override
  Widget build(BuildContext context) {
    // Define a function to send the post information
    sendInfo() {
      try {
        // Upload the image file
        uploadFile(widget.image);
        // Close the current screen and go back to the previous screen
        Navigator.of(context).pop();
      } catch (e) {
        // If there is an error, print the error message to the console
        print("An Error Occurred: $e");
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
          title: "Create Post", // Sets the title of the app bar.
          color: const Color(0xFFDDDDDD), // Sets the color of the title.
          child: const Text("Create Post"), // The actual text of the title.
        ),
        actions: [
          TextButton(
              onPressed: () => sendInfo(),
              child: const Text(
                "Send",
                style: TextStyle(color: Color(0xFFDDDDDD)),
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
                  const Text(
                      "Post Description"), // The label for the text field.
                  TextField(
                    controller:
                        nameController, // The controller for the text field.
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
