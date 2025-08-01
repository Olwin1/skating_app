import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:patinka/api/config/config.dart";
import "package:patinka/api/connections.dart";
import "package:patinka/l10n/app_localizations.dart";
import "package:patinka/misc/default_profile.dart";
import "package:patinka/profile/list_type.dart";
import "package:patinka/profile/profile_page/profile_page.dart";
import "package:patinka/swatch.dart";
import "package:shimmer/shimmer.dart";

// UserListWidget class creates a stateful widget that displays a list of users
class UserListWidget extends StatefulWidget {
  // Constructor for UserListWidget
  const UserListWidget(
      {required this.user,
      required this.listType,
      required this.refreshPage,
      super.key,
      this.ownerUser});

  // Title for the widget
  final Map<String, dynamic> user;
  final Map<String, dynamic>? ownerUser;
  final ListType listType;
  final VoidCallback refreshPage;
  // Creates the state for the UserListWidget
  @override
  State<UserListWidget> createState() => _UserListWidget();
}

// _UserListWidget class is the state of the UserListWidget
class _UserListWidget extends State<UserListWidget> {
  void handlePress() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (final context) => Profile(
                  userId: widget.user["user_id"],
                  user: widget.user,
                  friend:
                      widget.listType == ListType.friendsList ? true : false,
                )));
  }

  void handleDelete() async {
    switch (widget.listType) {
      case ListType.followersList:
        await ConnectionsAPI.unfollowerUser(widget.user["user_id"]);
        widget.refreshPage();

      case ListType.followingList:
        await ConnectionsAPI.unfollowUser(widget.user["user_id"]);
        widget.refreshPage();
      case ListType.friendsList:
        await ConnectionsAPI.unfriendUser(widget.user["user_id"]);
        widget.refreshPage();
    }
  }

  // Builds the widget
  @override
  Widget build(final BuildContext context) => GestureDetector(
      onTap: handlePress,
      child: Container(
          decoration: BoxDecoration(
            color: const Color(0xbb000000),
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // CircleAvatar with a radius of 26 and a background image from the assets folder
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                child: widget.user["avatar_id"] != null
                    ? CachedNetworkImage(
                        placeholder: (final context, final url) =>
                            Shimmer.fromColors(
                                baseColor: shimmer["base"]!,
                                highlightColor: shimmer["highlight"]!,
                                child: Image.asset(
                                    "assets/placeholders/1080.png")),
                        imageUrl:
                            '${Config.uri}/image/thumbnail/${widget.user["avatar_id"]}',
                        imageBuilder: (final context, final imageProvider) =>
                            Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape
                                .circle, // Set the shape of the container to a circle
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                      )
                    : const DefaultProfile(radius: 26),
              ),
              // Text widget with the text "username"
              Text(
                widget.user["username"] ??
                    AppLocalizations.of(context)!.username,
                style: TextStyle(color: swatch[701]),
              ),
              const Spacer(
                flex: 10,
              ),
              // TextButton with an onPressed function that prints test value "ee" and a child text widget with the text "Follow"
              widget.ownerUser == null
                  ? TextButton(
                      onPressed: handleDelete,
                      child: Text(widget.listType == ListType.followingList
                          ? AppLocalizations.of(context)!.unfollow
                          : widget.listType == ListType.followersList
                              ? "Remove"
                              : "Unfriend"))
                  : const SizedBox.shrink(),
              const Spacer()
            ],
          )));
}
