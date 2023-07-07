import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:skating_app/api/connections.dart';
import 'package:skating_app/common_logger.dart';

import '../swatch.dart';
import 'edit_profile.dart';

class FollowButton extends StatefulWidget {
  final String user;
  final Map<String, dynamic>? userObj;

  // Constructor that takes a `key` and a required `user` parameter
  const FollowButton({super.key, required this.user, required this.userObj});

  // Overrides the `createState` method and returns an instance of `_FollowButtonState`
  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  // Initializes the default `type` to "follow"
  String type = "follow";

  @override
  initState() {
    // Runs once when the widget is inserted into the widget tree
    if (widget.user != "0") {
      // Calls `doesFollow` function to check if the user is being followed
      doesFollow(widget.user).then((value) => {
            // Logs the response from `doesFollow`
            commonLogger.v("User does follow: ${value.toString()}"),
            // If the user is already followed, update `type` to "following" or "requested"
            if (value[0])
              {
                mounted
                    ? setState(() =>
                        type = value[1] == false ? "following" : "requested")
                    : null
              }
          });
    }
    // Calls the parent `initState` method
    super.initState();
  }

  // Function to handle button press
  handlePressed() {
    if (widget.user != "0") {
      if (type == "follow") {
        // Calls `followUser` function to follow/unfollow the user
        followUser(widget.user).then((value) => {
              // Logs the response from `followUser`
              commonLogger.v("Follow successful: $value"),
              // If follow request is successful, update `type` to "requested"
              if (value["requested"] == true)
                {mounted ? setState(() => type = "requested") : null}
              else
                {
                  // If the user is being followed, update `type` to "following"
                  mounted ? setState(() => type = "following") : null
                }
            });
      } else {
        unfollowUser(widget.user).then((value) => {
              // Logs the response from `followUser`
              commonLogger.v("Unfollow success $value"),
              // If follow request is successful, update `type` to "requested"
              mounted ? setState(() => type = "follow") : null
            });
      }
    } else {
      // If the user is editing their profile, navigate to the `EditProfile` screen
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditProfile(
                    user: widget.userObj,
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Returns a `TextButton` widget with `onPressed` and `child` properties
    return Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
            color: Color.fromARGB(125, 0, 0, 0),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: TextButton(
            // Calls the `handlePressed` function when the button is pressed
            onPressed: () => handlePressed(),
            // Conditionally displays different text based on the value of `type`
            child: widget.user != "0"
                ? Text(
                    type == "follow"
                        ? AppLocalizations.of(context)!.follow
                        : type == "requested"
                            ? AppLocalizations.of(context)!.requested
                            : AppLocalizations.of(context)!.following,
                    style: TextStyle(color: swatch[401]))
                : Text(AppLocalizations.of(context)!.editProfile,
                    style: TextStyle(color: swatch[401]))));
  }
}
