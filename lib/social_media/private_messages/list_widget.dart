import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skating_app/objects/user.dart';
import '../../api/config.dart';
import '../../swatch.dart';
import 'private_message.dart';

class ListWidget extends StatefulWidget {
  // Create HomePage Class
  const ListWidget(
      {Key? key,
      required this.userId,
      required this.index,
      required this.channel,
      required this.desc})
      : super(key: key); // Take 2 arguments optional key and title of post
  final int index; // Define title argument
  final String userId; // Define title argument
  final String channel; // Define title argument
  final String desc; // Define title argument
  @override
  State<ListWidget> createState() => _ListWidget(); //Create state for widget
}

class _ListWidget extends State<ListWidget> {
  Map<String, dynamic>? user;
  @override
  void initState() {
    getUserCache(widget.userId).then((value) => {
          setState(
            () => user = value,
          )
        });
    super.initState();
  }

  @override // Override existing build method
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.all(8), // Add padding so doesn't touch edges
      child: TextButton(
        // Make list widget clickable
        onPressed: () => Navigator.push(
            // When button pressed
            context,
            MaterialPageRoute(
                builder: (context) => PrivateMessage(
                    // Add private message page to top of navigation stack
                    index: 1,
                    channel: widget.channel,
                    user: user))), //When list widget clicked
        child: Row(
          // Create a row
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Add List image to one row and buttons to another
            user == null || user?["avatar"] == null
                // If there is no cached user information or avatar image, use a default image
                ? CircleAvatar(
                    radius: 36, // Set the radius of the circular avatar image
                    child: ClipOval(
                      child: Image.asset("assets/placeholders/default.png"),
                    ),
                  )
                // If there is cached user information and an avatar image, use the cached image
                : Flexible(
                    child: CachedNetworkImage(
                        imageUrl: '${Config.uri}/image/${user!["avatar"]}',
                        httpHeaders: const {"thumbnail": "true"},
                        placeholder: (context, url) => CircleAvatar(
                              // Set the radius of the circular avatar image
                              child: ClipOval(
                                child: Image.asset(
                                    "assets/placeholders/default.png"),
                              ),
                            ),
                        imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                shape: BoxShape
                                    .circle, // Set the shape of the container to a circle
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.contain),
                              ),
                            )),
                  ),
            const Padding(
                padding:
                    EdgeInsets.only(left: 16)), // Space between avatar and text
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
                          color: swatch[300],
                        )),
                    Text(widget.desc,
                        style: const TextStyle(
                            color: Color.fromARGB(
                                255, 77, 77, 77), // Set colour to light grey
                            height: 1.5)), // Last message sent from user
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
