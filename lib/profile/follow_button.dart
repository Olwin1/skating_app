import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:patinka/api/connections.dart';
import 'package:patinka/common_logger.dart';

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

enum FollowState { follow, following, requested }

class _FollowButtonState extends State<FollowButton> {
  // Initializes the default `type` to "follow"
  FollowState type = FollowState.follow;

  @override
  void initState() {
    // Runs once when the widget is inserted into the widget tree
    if (widget.user != "0") {
      FollowState val = FollowState.follow;
      // Calls `doesFollow` function to check if the user is being followed
      ConnectionsAPI.doesFollow(widget.user).then((value) => {
            // Logs the response from `doesFollow`
            commonLogger.t("User does follow: ${value.toString()}"),
            // If the user is already followed, update `type` to "following" or "requested"
            if (!value["following"])
              {
                if (value["requested"]) {val = FollowState.requested}
              }
            else
              {val = FollowState.following},

            mounted ? setState(() => type = val) : null
          });
    }
    // Calls the parent `initState` method
    super.initState();
  }

  // Function to handle button press
  void handlePressed() {
    if (widget.user != "0") {
      if (type == FollowState.follow) {
        // Calls `followUser` function to follow/unfollow the user
        ConnectionsAPI.followUser(widget.user).then((value) => {
              // Logs the response from `followUser`
              commonLogger.t("Follow successful: $value"),
              // If follow request is successful, update `type` to "requested"
              if (value["requested"] == true)
                {mounted ? setState(() => type = FollowState.requested) : null}
              else
                {
                  // If the user is being followed, update `type` to "following"
                  mounted ? setState(() => type = FollowState.following) : null
                }
            });
      } else {
        ConnectionsAPI.unfollowUser(widget.user).then((value) => {
              // Logs the response from `followUser`
              commonLogger.t("Unfollow success $value"),
              // If follow request is successful, update `type` to "requested"
              mounted ? setState(() => type = FollowState.follow) : null
            });
      }
    } else {
      // If the user is editing their profile, navigate to the `EditProfile` screen
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => EditProfile(
            user: widget.userObj,
          ),
          opaque: false,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.0;
            const end = 1.0;
            var tween = Tween(begin: begin, end: end);
            var fadeAnimation = tween.animate(animation);
            return FadeTransition(
              opacity: fadeAnimation,
              child: child,
            );
          },
        ),
      );
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
                    type == FollowState.follow
                        ? AppLocalizations.of(context)!.follow
                        : type == FollowState.requested
                            ? AppLocalizations.of(context)!.requested
                            : AppLocalizations.of(context)!.following,
                    style: TextStyle(color: swatch[401]))
                : Text(AppLocalizations.of(context)!.editProfile,
                    style: TextStyle(color: swatch[401]))));
  }
}
