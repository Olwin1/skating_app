import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:skating_app/api/connections.dart';
import 'package:skating_app/common_logger.dart';

import '../swatch.dart';
import 'edit_profile.dart';

// Define a new StatelessWidget called FriendButton
class FriendButton extends StatefulWidget {
  final String user;
  final Map<String, dynamic>? userObj;

  // Constructor for FriendButton, which calls the constructor for its superclass (StatelessWidget)
  const FriendButton({super.key, required this.user, required this.userObj});

  @override
  State<FriendButton> createState() => _FriendButtonState();
}

// Define a State class for the FriendButton widget
class _FriendButtonState extends State<FriendButton> {
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
            commonLogger.v("Does follow user: ${value.toString()}"),
            // Update the button's type based on the result of the doesFollow method
            if (value[0])
              {
                mounted
                    ? setState(
                        () => type =
                            value[1] == false ? "following" : "requested",
                      )
                    : null
              }
            else if (value[2])
              {
                mounted
                    ? setState(
                        () => type = "incoming",
                      )
                    : null
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
            commonLogger.v("Follow user $value"),
            // Update the button's type based on the result of the followUser method
            if (value["requested"] == true)
              {
                mounted
                    ? setState(
                        () => type = "requested",
                      )
                    : null
              }
            else
              {
                mounted
                    ? setState(
                        () => type = "following",
                      )
                    : null
              }
          });
    } else {
      // Navigate to the EditProfile page if no user is specified
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditProfile(user: widget.userObj)));
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
