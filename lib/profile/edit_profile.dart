import 'package:flutter/material.dart';
import 'package:skating_app/objects/user.dart';

// Creates a EditProfile widget
class EditProfile extends StatefulWidget {
  const EditProfile({Key? key, required this.title})
      : super(
            key:
                key); // Take 2 arguments: optional key and required title of the post
  final String title;

  @override
  // Create state for the widget
  State<EditProfile> createState() => _EditProfile();
}

// The state class for the EditProfile widget
class _EditProfile extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    // Create an instance of the User class with an id of '1'
    User user = User("1");

    return Scaffold(
      appBar: AppBar(
        // Create appBar widget
        title: const Text("Edit Profile"), // Set title
      ),
      // Basic list layout element
      body: Container(),
    );
  }
}
