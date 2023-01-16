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
  @override // Override existing build method
  Widget build(BuildContext context) {
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
        body: ListView(children: const [
          Comment(index: 1)
        ])); // Create basic comments listView
  }
}
