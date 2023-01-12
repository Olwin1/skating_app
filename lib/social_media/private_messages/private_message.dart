import 'package:flutter/material.dart';

class PrivateMessage extends StatefulWidget {
  // Create HomePage Class
  const PrivateMessage({Key? key, required this.index})
      : super(key: key); // Take 2 arguments optional key and title of post
  final int index; // Define title argument
  @override
  State<PrivateMessage> createState() =>
      _PrivateMessage(); //Create state for widget
}

class _PrivateMessage extends State<PrivateMessage> {
  @override // Override existing build method
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: 80,
      padding: const EdgeInsets.all(8), // Add padding so doesn't touch edges
      color: const Color(0xFFFFFFFF), // For testing to highlight seperations
    ));
  }
}
