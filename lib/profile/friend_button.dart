import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:skating_app/api/connections.dart';

import '../swatch.dart';
import 'edit_profile.dart';

// Define a new StatelessWidget called FollowButton
class FollowButton extends StatefulWidget {
  final String user;

  // Constructor for FollowButton, which calls the constructor for its superclass (StatelessWidget)
  const FollowButton({super.key, required this.user});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

// Define a State class for the FollowButton widget
class _FollowButtonState extends State<FollowButton> {
  // Initialize the default type of the button as "follow"
  String type = "follow";

  // Define the initState method to set the initial state of the widget
  @override
  initState() {
    // Check if a user is specified in the widget's properties
    if (widget.user != "0") {
      // Call the doesFollow method to check if the user is being followed
      doesFollow(widget.user).then((value) => {
            // Print the result of the doesFollow method
            print(value.toString()),
            // Update the button's type based on the result of the doesFollow method
            if (value[0])
              {
                setState(
                  () => type = value[1] == false ? "following" : "requested",
                )
              }
            else if (value[2])
              {
                setState(
                  () => type = "incoming",
                )
              }
          });
    }
    // Call the superclass's initState method
    super.initState();
  }

  // Define a method to handle button presses
  handlePressed() {
    // Check if a user is specified in the widget's properties
    if (widget.user != "0") {
      // Call the followUser method to follow the user
      followUser(widget.user).then((value) => {
            // Print the result of the followUser method
            print(value),
            // Update the button's type based on the result of the followUser method
            if (value["requested"] == true)
              {
                setState(
                  () => type = "requested",
                )
              }
            else
              {
                setState(
                  () => type = "following",
                )
              }
          });
    } else {
      // Navigate to the EditProfile page if no user is specified
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const EditProfile()));
    }
  }

  // Override the build method of StatelessWidget to return a TextButton widget
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () =>
            handlePressed(), // Call handlePressed when the button is pressed
        child: widget.user != "0"
            ? Text(
                // Display different text on the button based on its type
                type == "follow"
                    ? AppLocalizations.of(context)!.follow
                    : type == "requested"
                        ? AppLocalizations.of(context)!.requested
                        : type == "following"
                            ? AppLocalizations.of(context)!.following
                            : "incoming",
                // Set the color of the button's text
                style: TextStyle(color: swatch[400]))
            : Text("Edit Profile", style: TextStyle(color: swatch[400])));
  }
}
