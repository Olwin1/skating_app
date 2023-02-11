import 'package:flutter/material.dart';
import 'package:skating_app/objects/user.dart';

// Define the EditProfile widget which extends StatefulWidget
class EditProfile extends StatefulWidget {
  const EditProfile({Key? key, required this.title}) : super(key: key);
  // title is a required parameter
  final String title;

  @override
  // Create the state for the EditProfile widget
  State<EditProfile> createState() => _EditProfile();
}

// Define the state for the EditProfile widget
class _EditProfile extends State<EditProfile> {
  @override
  // Build the UI for the EditProfile widget
  Widget build(BuildContext context) {
    // Create an instance of the User object
    User user = User("1");

    return Scaffold(
      // Define an app bar with a title "Edit Profile"
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      // Define the body of the Scaffold
      body: Column(children: [
        // First column with an avatar and an edit picture button
        Column(
          children: [
            // Display the avatar
            const CircleAvatar(
              radius: 36,
              backgroundImage: AssetImage("assets/placeholders/150.png"),
            ),
            // Display the edit picture button
            TextButton(
                onPressed: () => print("pressed"),
                child: const Text("Edit Picture"))
          ],
        ),
        // Second column with display name
        Column(
          children: const [
            Text("Display Name"),
            TextField(),
          ],
        ),
        // Third column with username
        Column(
          children: const [
            Text("Username"),
            TextField(),
          ],
        ),
        // Fourth column with about me
        Column(
          children: const [
            Text("About Me"),
            TextField(),
          ],
        )
      ]),
    );
  }
}
