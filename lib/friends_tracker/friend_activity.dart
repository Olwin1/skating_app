import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skating_app/api/config.dart';

import '../objects/user.dart';
import '../swatch.dart';

class FriendActivity extends StatefulWidget {
  final List<Map<String, dynamic>> sessions;
  // Create FriendActivity widget
  const FriendActivity(
      {Key? key, required this.searchOpened, required this.sessions})
      : super(key: key); // Take 2 arguments optional key and title of post
  final bool searchOpened;
  @override
  State<FriendActivity> createState() =>
      _FriendActivity(); //Create state for widget
}

class _FriendActivity extends State<FriendActivity> {
  @override // Override existing build method
  Widget build(BuildContext context) {
    return widget.searchOpened
        ? Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 32),
            height: 136,
            width: 600,
            child: ListView(
              // This next line does the trick.
              scrollDirection: Axis.horizontal,
              children: widget.sessions
                  .map((session) => FriendActivityProfile(session: session))
                  .toList(),
            ))
        : Container();
  }
}

class FriendActivityProfile extends StatefulWidget {
  final Map<String, dynamic> session;

  // Create FriendActivity widget
  const FriendActivityProfile({Key? key, required this.session})
      : super(key: key); // Take 2 arguments optional key and title of post
  @override
  State<FriendActivityProfile> createState() =>
      _FriendActivityProfile(); //Create state for widget
}

class _FriendActivityProfile extends State<FriendActivityProfile> {
  // Define a variable to hold the user cache
  Map<String, dynamic>? userCache;

  @override
  void initState() {
    super.initState();
    // Call the getUserCache function to retrieve user information and update the state
    getUserCache(widget.session["author"])
        .then((value) => setState(() => userCache = value));
  }

  @override // Override the existing build method to create the user profile
  Widget build(BuildContext context) {
    return Column(children: [
      // Create a button with an icon that represents the user
      TextButton(
        onPressed: () => print(
            "Pressed user icon"), // When the button is pressed, print a message
        child: userCache == null || userCache!["avatar"] == null
            // If there is no cached user information or avatar image, use a default image
            ? Shimmer.fromColors(
                baseColor: const Color(0x66000000),
                highlightColor: const Color(0xff444444),
                child: CircleAvatar(
                  // Create a circular avatar icon
                  radius: 32, // Set radius to 36
                  backgroundColor: swatch[900]!,
                  // backgroundImage: AssetImage(
                  //     "assets/placeholders/default.png"), // Set avatar to placeholder images
                ))
            // If there is cached user information and an avatar image, use the cached image
            : CachedNetworkImage(
                imageUrl: '${Config.uri}/image/${userCache!["avatar"]}',
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape
                        .circle, // Set the shape of the container to a circle
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
              ),
      ),
      // Display the username of the user whose information is cached
      Text(userCache != null ? userCache!["username"] : "Username")
    ]);
  }
}
