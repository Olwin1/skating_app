import 'package:flutter/material.dart';
import 'private_message.dart';

class Comment extends StatefulWidget {
  // Create HomePage Class
  const Comment({Key? key, required this.index})
      : super(key: key); // Take 2 arguments optional key and title of post
  final int index; // Define title argument
  @override
  State<Comment> createState() => _Comment(); //Create state for widget
}

class _Comment extends State<Comment> {
  @override // Override existing build method
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(8), // Add padding so doesn't touch edges
      child: TextButton(
        onPressed: () => print("Pressed"),
        // Make list widget clickable
        onLongPress: () => print("longPress"), //When list widget clicked
        child: const Text("eeeeeeeeeeeeeeeeeee"),
      ),
    );
  }
}
