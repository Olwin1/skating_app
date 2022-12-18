import 'package:flutter/material.dart';

class PostWidget extends StatefulWidget {
  // Create HomePage Class
  const PostWidget({Key? key, required this.title})
      : super(key: key); // Take 2 arguments optional key and title of post
  final String title; // Define title argument
  @override
  State<PostWidget> createState() => _PostWidget(); //Create state for widget
}

class _PostWidget extends State<PostWidget> {
  @override // Override existing build method
  Widget build(BuildContext context) {
    return Container(
        height: 50, color: const Color(0xFFFFE306)); // Create basic containter
  }
}
