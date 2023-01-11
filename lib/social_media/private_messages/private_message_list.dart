import 'dart:ui';

import 'package:flutter/material.dart';
import '../../objects/user.dart';
import 'list_widget.dart';

class PrivateMessageList extends StatefulWidget {
  // Create HomePage Class
  const PrivateMessageList({Key? key, required this.user, required this.index})
      : super(key: key); // Take 2 arguments optional key and title of post
  final User user; // Define title argument
  final int index; // Define title argument
  @override
  State<PrivateMessageList> createState() =>
      _PrivateMessageList(); //Create state for widget
}

class _PrivateMessageList extends State<PrivateMessageList> {
  @override // Override existing build method
  Widget build(BuildContext context) {
    return Scaffold(
        //Create a scaffold
        appBar: AppBar(), // Add a basic app bar
        body: Container(
          padding:
              const EdgeInsets.all(8), // Add padding so doesn't touch edges
          color:
              const Color(0xFFFFE306), // For testing to highlight seperations
          child: ListView(
            // Create a row
            children: [
              const Padding(
                // Make Search Bar Padded
                padding: EdgeInsets.only(bottom: 16),
                child: Flexible(
                  child: TextField(
                    // Create text inout field
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'search', //Placeholder text
                    ),
                  ),
                ),
              ),
              Title(
                  // Private Messages title
                  color: const Color(0xffcfcfcf),
                  child: const Text(
                    "Private Messages",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  )),
              const ListWidget(index: 1)
            ], // Set child to a list widget
          ),
        ));
  }
}
