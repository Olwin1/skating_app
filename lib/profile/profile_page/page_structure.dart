import "package:flutter/material.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/profile/follow_button.dart";
import "package:patinka/profile/friend_icon_button.dart";
import "package:patinka/profile/profile_page/profile_banner.dart";
import "package:patinka/profile/profile_page/user_posts_list.dart";
import "package:patinka/swatch.dart";

class PageStructure extends StatelessWidget {
  const PageStructure(
      {required this.user, required this.userId, required this.show, required this.findWidgetMetaData, required this.setCurrentImage, super.key,
      this.avatar,
      this.friend});

  final String? avatar;
  final Map<String, dynamic>? user;
  final String userId;
  final Function show;
  final Function findWidgetMetaData;
  final Function setCurrentImage;
  final bool? friend;
  @override
  Widget build(final BuildContext context) => ListView(shrinkWrap: true, children: [
      ProfileBanner(
        avatar: avatar,
        user: user,
      ), // Row to display the number of friends, followers, and following
      // Display the user's name
      Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: const Color.fromARGB(125, 0, 0, 0),
            borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(8),
        child:
            Text(user?["username"] ?? "", style: TextStyle(color: swatch[601])),
      ),
      // Display the user's bio
      (user != null && user!["description"] != null)
          ? Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(125, 0, 0, 0),
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.all(8),
              child: Text(
                  textAlign: TextAlign.justify,
                  user!["description"].toString(),
                  style: TextStyle(color: swatch[801])),
            )
          : const SizedBox.shrink(),
      // Row with two text buttons
      Row(children: [
        // First text button
        Expanded(
            // Expand button to empty space
            child: FollowButton(
          user: userId,
          userObj: user,
        )), // Button text
        // Second text button
        Expanded(
            child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
              color: Color.fromARGB(125, 0, 0, 0),
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: TextButton(
              // Expand button to empty space
              onPressed: () => commonLogger
                  .i("pressed"), // Prints "pressed" when button is pressed
              child: Text(AppLocalizations.of(context)!.shareProfile,
                  style: TextStyle(color: swatch[401]))),
        )), // Button text
        FriendIconButton(user: user, friend: friend)
      ]),
      // Expanded grid view with images
      UserPostsList(
          user: user,
          imageViewerController: show,
          metadata: findWidgetMetaData,
          setCurrentImage: setCurrentImage)
    ]);
}
