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
    return Container(
      padding: const EdgeInsets.all(0), // Add padding so doesn't touch edges
      color: const Color(0xFFFFE306), // For testing to highlight seperations
      child: Row(
        // Create a row
        crossAxisAlignment: CrossAxisAlignment.center, // Align children center
        children: const [ListWidget(index: 1)], // Set child to a list widget
      ),
    );
  }
}
