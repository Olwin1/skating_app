import 'package:flutter/material.dart';

class SaveSession extends StatefulWidget {
  // Create SaveSession Class
  const SaveSession({Key? key}) : super(key: key);
  @override
  State<SaveSession> createState() => _SaveSession(); //Create state for widget
}

class _SaveSession extends State<SaveSession> {
  @override // Override existing build method
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Create appBar
          leadingWidth: 48, // Remove extra leading space
          centerTitle: false, // Align title to left
          title: Title(
            title: "Save Session", //Set title to Save Session
            color: const Color(0xFFDDDDDD),
            child: const Text("Save Session"),
          ),
        ),
        body: Container());
  }
}
