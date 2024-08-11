import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:patinka/misc/default_profile.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/api/config.dart';
import 'package:patinka/common_logger.dart';

import '../api/social.dart';
import '../swatch.dart';

class FriendActivity extends StatefulWidget {
  final List<Map<String, dynamic>> sessions;
  // Create FriendActivity widget
  const FriendActivity(
      {super.key,
      required this.mapController,
      required this.searchOpened,
      required this.sessions}); // Take 2 arguments optional key and title of post
  final bool searchOpened;
  final MapController mapController;
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
                  .map((session) => FriendActivityProfile(session: session, mapController: widget.mapController))
                  .toList(),
            ))
        : Container();
  }
}

class FriendActivityProfile extends StatefulWidget {
  final Map<String, dynamic> session;
  final MapController mapController;

  // Create FriendActivity widget
  const FriendActivityProfile(
      {super.key,
      required this.mapController,
      required this.session}); // Take 2 arguments optional key and title of post
  @override
  State<FriendActivityProfile> createState() =>
      _FriendActivityProfile(); //Create state for widget
}

class _FriendActivityProfile extends State<FriendActivityProfile> {
  // Define a variable to hold the user cache
  Map<String, dynamic>? userCache;
  String? avatar;

  @override
  void initState() {
    super.initState();
    // Call the SocialAPI.getUser function to retrieve user information and update the state
    SocialAPI.getUser(widget.session["author_id"]).then((value) => mounted
        ? setState(() {
            userCache = value;
            avatar = value["avatar_id"];
          })
        : null);
  }

  @override // Override the existing build method to create the user profile
  Widget build(BuildContext context) {
    return Column(children: [
      // Create a button with an icon that represents the user
      TextButton(
        onPressed: () => {commonLogger.d(
            "Pressed user icon"), widget.mapController.move(LatLng(0, 0), 17.0)}, // When the button is pressed, print a message
        child: userCache == null || avatar == null
            // If there is no cached user information or avatar image, use a default image
            ? Shimmer.fromColors(
                baseColor: shimmer["base"]!,
                highlightColor: shimmer["highlight"]!,
                child: CircleAvatar(
                  // Create a circular avatar icon
                  radius: 32, // Set radius to 36
                  backgroundColor: swatch[900],
                ))
            // If there is cached user information and an avatar image, use the cached image
            : avatar != "default"
                ? CachedNetworkImage(
                    imageUrl: '${Config.uri}/image/${userCache!["avatar_id"]}',
                    imageBuilder: (context, imageProvider) => Container(
                      height: 64,
                          width: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape
                            .circle, // Set the shape of the container to a circle
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                  )
                : const DefaultProfile(radius: 32),
      ),
      // Display the username of the user whose information is cached
      Text(userCache != null ? userCache!["username"] : "Username", style: TextStyle(color: swatch[900], fontWeight: FontWeight.bold),)
    ]);
  }
}
