import 'package:flutter/material.dart';

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
    return Scaffold(
      // Define an app bar with a title "Edit Profile"
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      // Define the body of the Scaffold
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Padding(
                padding: EdgeInsets.only(top: 8), // Add padding above text
                child: Text("Display Name"),
              ),
              TextField(
                // Remove default padding
                decoration: InputDecoration(
                    isDense: true, contentPadding: EdgeInsets.zero),
              ),
            ],
          ),
          // Third column with username
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Padding(
                padding: EdgeInsets.only(top: 8), // Add padding above text
                child: Text("Username"),
              ),
              TextField(
                // Remove default padding
                decoration: InputDecoration(
                    isDense: true, contentPadding: EdgeInsets.zero),
              ),
            ],
          ),
          // Fourth column with country
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text("Country"),
              ),
              TextField(
                // Remove default padding
                decoration: InputDecoration(
                    isDense: true, contentPadding: EdgeInsets.zero),
              ),
            ],
          ),
          // Fifth column with about me
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text("About Me"),
              ),
              TextField(
                // Remove default padding
                decoration: InputDecoration(
                    isDense: true, contentPadding: EdgeInsets.zero),
              ),
            ],
          )
        ]),
      ),
    );
  }
}
