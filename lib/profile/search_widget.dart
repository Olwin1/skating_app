import 'package:flutter/material.dart';

// Define a stateful widget called UserListWidget.
class UserListWidget extends StatefulWidget {
  // Constructor that accepts an optional key.
  const UserListWidget({Key? key}) : super(key: key);

  @override
  // Create the state object for this widget.
  State<UserListWidget> createState() => _UserListWidget();
}

// The state object for the UserListWidget.
class _UserListWidget extends State<UserListWidget> {
  @override
  // Define the build method that returns a widget tree.
  Widget build(BuildContext context) {
    // Return a TextField widget with an InputDecoration.
    return const TextField(
      maxLength: 400,
      decoration:
          InputDecoration(isDense: true, contentPadding: EdgeInsets.zero),
    );
  }
}
