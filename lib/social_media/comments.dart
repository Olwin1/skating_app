import 'package:comment_box/comment/comment.dart';
import 'package:flutter/material.dart';
import 'package:skating_app/social_media/private_messages/comment.dart';

class Comments extends StatefulWidget {
  // Create HomePage Class
  const Comments({Key? key})
      : super(key: key); // Take 2 arguments optional key and title of post
  @override
  State<Comments> createState() => _Comments(); //Create state for widget
}

class _Comments extends State<Comments> {
  late FocusNode focus; // Define focus node
  @override // Override existing build method
  Widget build(BuildContext context) {
    focus = FocusNode(); // Assign focus node
    return Scaffold(
      appBar: AppBar(
        // Create appBar
        leadingWidth: 48, // Remove extra leading space
        centerTitle: false, // Align title to left
        title: Title(
          title: "Comments", //Set title to comments
          color: const Color(0xFFDDDDDD),
          child: const Text("Comments"),
        ),
      ),
      body: CommentBox(
          // Create CommentBox widget
          focusNode: focus, // Pass focus node to input
          userImage: CommentBox.commentImageParser(
              // Avatar image
              imageURLorPath: "assets/placeholders/150.png"),
          labelText: 'Write a comment...',
          errorText: 'Comment cannot be blank',
          withBorder: false,
          sendButtonMethod: () {
            // When send button pressed
            /*if (formKey.currentState!.validate()) {
              print(commentController.text);
              setState(() {
                var value = {
                  'name': 'New User',
                  'pic':
                      'https://lh3.googleusercontent.com/a-/AOh14GjRHcaendrf6gU5fPIVd8GIl1OgblrMMvGUoCBj4g=s400',
                  'message': commentController.text,
                  'date': '2021-01-01 12:00:00'
                };
                filedata.insert(0, value);
              });
              commentController.clear();
              FocusScope.of(context).unfocus();
            } else {
              print("Not validated");
            }*/
          },
          //formKey: formKey,
          //commentController: commentController,
          backgroundColor: Colors.pink, // Set background colour to pink
          textColor: Colors.white, // Make text white
          sendWidget: // Icon on left of input
              const Icon(Icons.send_sharp, size: 30, color: Colors.white),
          child: ListView(children: [Comment(index: 1, focus: focus)])),
    ); // Create basic comments listView
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    focus.dispose();
    super.dispose();
  }
}
