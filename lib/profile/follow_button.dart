import "package:flutter/material.dart";
import "package:patinka/api/config/config.dart";
import "package:patinka/api/connections.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/l10n/app_localizations.dart";
import "package:patinka/profile/edit_profile/edit_profile.dart";
import "package:patinka/swatch.dart";

class FollowButton extends StatefulWidget {
  // Constructor that takes a `key` and a required `user` parameter
  const FollowButton({required this.user, required this.userObj, super.key});
  final String user;
  final Map<String, dynamic>? userObj;

  // Overrides the `createState` method and returns an instance of `_FollowButtonState`
  @override
  State<FollowButton> createState() => _FollowButtonState();
}

enum FollowState { follow, following, requested }

class _FollowButtonState extends State<FollowButton> {
  // Initializes the default `type` to "follow"
  FollowState type = FollowState.follow;
  String isUser = "0";

  @override
  void initState() {
    // Runs once when the widget is inserted into the widget tree
    if (widget.user != "0") {
      isUser = widget.user;
      storage.getId().then((final value) => {
            if (isUser == value) {setState(() => isUser = "0")}
          });

      // If the user is already followed, update `type` to "following" or "requested"
      if (widget.userObj == null ||
          widget.userObj!["user_follows"] == null ||
          widget.userObj!["user_follows"]!["following"] == null) {
        type = FollowState.follow;
      } else if (!widget.userObj?["user_follows"]["following"]) {
        if (widget.userObj?["user_follows"]["requested"]) {
          type = FollowState.requested;
        }
      } else {
        type = FollowState.following;
      }
    }
    // Calls the parent `initState` method
    super.initState();
  }

  // Function to handle button press
  void handlePressed() {
    if (widget.user != "0") {
      if (type == FollowState.follow) {
        // Calls `followUser` function to follow/unfollow the user
        ConnectionsAPI.followUser(widget.user).then((final value) => {
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
        ConnectionsAPI.unfollowUser(widget.user).then((final value) => {
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
          pageBuilder:
              (final context, final animation, final secondaryAnimation) =>
                  EditProfile(
            user: widget.userObj,
          ),
          opaque: false,
          transitionsBuilder: (final context, final animation,
              final secondaryAnimation, final child) {
            const begin = 0.0;
            const end = 1.0;
            final tween = Tween(begin: begin, end: end);
            final fadeAnimation = tween.animate(animation);
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
  Widget build(final BuildContext context) => Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
          color: Color.fromARGB(125, 0, 0, 0),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: TextButton(
          // Calls the `handlePressed` function when the button is pressed
          onPressed: handlePressed,
          // Conditionally displays different text based on the value of `type`
          child: isUser != "0"
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
