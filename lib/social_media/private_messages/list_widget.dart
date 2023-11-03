import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../api/config.dart';
import '../../misc/default_profile.dart';
import '../../swatch.dart';
import 'private_message.dart';

class ListWidget extends StatefulWidget {
  // Create HomePage Class
  const ListWidget(
      {Key? key,
      required this.index,
      required this.channel,
      required this.desc,
      required this.currentUser})
      : super(key: key); // Take 2 arguments optional key and title of post
  final int index; // Define title argument
  final Map<String, dynamic> channel; // Define title argument
  final String desc; // Define title argument
  final String currentUser;

  @override
  State<ListWidget> createState() => _ListWidget(); //Create state for widget
}

class _ListWidget extends State<ListWidget> {
  @override // Override existing build method
  Widget build(BuildContext context) {
    Map<String, dynamic>? user;
    for (var participant in widget.channel["participants"]) {
      if (participant["users"]["user_id"] != widget.currentUser) {
        user = participant["users"];
        break;
      }
    }
    return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xb5000000),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          height: 82,
          margin: const EdgeInsets.symmetric(
              horizontal: 8), // Add padding so doesn't touch edges
          padding: const EdgeInsets.symmetric(
              vertical: 8), // Add padding so doesn't touch edges
          child: TextButton(
            // Make list widget clickable
            onPressed: () => {
              Navigator.push(
                  // When button pressed
                  context,
                  MaterialPageRoute(
                      builder: (context) => PrivateMessage(
                            // Add private message page to top of navigation stack
                            index: 1,
                            channel: widget.channel,
                            user: user, currentUser: widget.currentUser,
                          ))),
            }, //When list widget clicked
            child: Row(
              // Create a row
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Add List image to one row and buttons to another
                user == null
                    // If there is no cached user information or avatar image, use a default image
                    ? Shimmer.fromColors(
                        baseColor: shimmer["base"]!,
                        highlightColor: shimmer["highlight"]!,
                        child: CircleAvatar(
                          // Create a circular avatar icon
                          radius: 36, // Set radius to 36
                          backgroundColor: swatch[900],
                        ))
                    // If there is cached user information and an avatar image, use the cached image
                    : Flexible(
                        child: (user["avatar_id"] != null &&
                                user["avatar_id"] != "default")
                            ? CachedNetworkImage(
                                imageUrl:
                                    '${Config.uri}/image/${user["avatar_id"]}',
                                httpHeaders: const {"thumbnail": "true"},
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                        baseColor: shimmer["base"]!,
                                        highlightColor: shimmer["highlight"]!,
                                        child: CircleAvatar(
                                          // Create a circular avatar icon
                                          radius: 36, // Set radius to 36
                                          backgroundColor: swatch[900],
                                        )),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape
                                            .circle, // Set the shape of the container to a circle
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.contain),
                                      ),
                                    ))
                            : const DefaultProfile(radius: 36),
                      ),
                const Padding(
                    padding: EdgeInsets.only(
                        left: 16)), // Space between avatar and text
                Flexible(
                  flex: 6,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Create a column aligned to the left
                        const Padding(
                          //Add padding to the top to move the text down a bit
                          padding: EdgeInsets.only(top: 10),
                        ),
                        Text(
                            //Message target's Name
                            user?["username"] ?? "Channel",
                            style: TextStyle(
                              color: swatch[301],
                            )),
                        Text(widget.desc,
                            style: TextStyle(
                                color: swatch[601], // Set colour to light grey
                                height: 1.5)), // Last message sent from user
                      ]),
                ),
              ],
            ),
          ),
        ));
  }
}
