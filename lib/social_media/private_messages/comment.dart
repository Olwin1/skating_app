import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skating_app/objects/user.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../api/config.dart';
import '../../swatch.dart';

class Comment extends StatefulWidget {
  final Map<String, dynamic> comment;

  // Create HomePage Class
  const Comment(
      {Key? key, required this.index, this.focus, required this.comment})
      : super(key: key); // Take 2 arguments optional key and title of post
  final int index; // Define title argument
  final FocusNode? focus; // Define focus argument
  @override
  State<Comment> createState() => _Comment(); //Create state for widget
}

class _Comment extends State<Comment> {
  Map<String, dynamic>? user;
  @override
  void initState() {
    getUserCache(widget.comment["sender"]).then((value) => mounted
        ? setState(
            () => user = value,
          )
        : null);
    super.initState();
  }

  @override // Override existing build method
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: swatch[401]!)),
        //borderRadius: BorderRadius.circular(8),
        color: const Color.fromARGB(125, 0, 0, 0),
      ),
      padding: const EdgeInsets.all(4), // Add padding so doesn't touch edges
      child: TextButton(
        onPressed: () => print("Pressed"),
        // Make list widget clickable
        onLongPress: () => print("longPress"), //When list widget clicked
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Create Row
          children: [
            Padding(
                padding: const EdgeInsets.only(
                  // Only give right of avatar padding
                  right: 8,
                ),
                child: user == null || user!["avatar"] == null
                    // If there is no cached user information or avatar image, use a default image
                    ? CircleAvatar(
                        radius:
                            25, // Set the radius of the circular avatar image
                        child: ClipOval(
                          child: Image.asset("assets/placeholders/default.png"),
                        ),
                      )
                    // If there is cached user information and an avatar image, use the cached image
                    : CachedNetworkImage(
                        imageUrl:
                            '${Config.uri}/image/thumbnail/${user!["avatar"]}',
                        placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: const Color(0x66000000),
                            highlightColor: const Color(0xff444444),
                            child: CircleAvatar(
                              // Create a circular avatar icon
                              radius: 25, // Set radius to 36
                              backgroundColor: swatch[900]!,
                              // backgroundImage: AssetImage(
                              //     "assets/placeholders/default.png"), // Set avatar to placeholder images
                            )),
                        imageBuilder: (context, imageProvider) => Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape
                                    .circle, // Set the shape of the container to a circle
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ))),
            Expanded(
                // Expanded Widget Wrapper
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Put rest on right
                  children: [
                    RichText(
                      // Create top row
                      text: TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                              text: user != null
                                  ? user!["username"]
                                  : "", // User's Display Name
                              style:
                                  TextStyle(color: swatch[101])), // Set colour
                          const WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: SizedBox(width: 6)),
                          TextSpan(
                            text: timeago
                                .format(DateTime.parse(widget.comment["date"]))
                                .toString(), //Time since sent
                            style: TextStyle(color: swatch[501]), // Set colour
                          )
                        ],
                      ),
                    ),
                    Text(
                      widget.comment["content"],
                      textAlign: TextAlign.start,
                      style: TextStyle(color: swatch[801]),
                    ), // Create message content
                    // Create footer

                    Row(
                        mainAxisAlignment: MainAxisAlignment
                            .end, // Align row on right of screen
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    8), // Apply padding only to left and right
                            child: TextButton(
                              // Create text button
                              onPressed: () => widget.focus
                                  ?.requestFocus(), // When reply pressed focus on text input
                              child: Text(
                                // Reply Placeholder
                                AppLocalizations.of(context)!.reply,
                                textAlign:
                                    TextAlign.end, // Align with right of screen
                                style: TextStyle(
                                    color: swatch[50],
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    8), // Apply padding only to left and right
                            child: Text(
                              AppLocalizations.of(context)!
                                  .like, // Like Placeholder
                              textAlign:
                                  TextAlign.end, // Align with right of screen
                              style: TextStyle(
                                  color: swatch[50],
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    8), // Apply padding only to left and right
                            child: Text(
                              AppLocalizations.of(context)!
                                  .dislike, // Dislike placeholder
                              textAlign:
                                  TextAlign.end, // Align with right of screen
                              style: TextStyle(
                                  color: swatch[50],
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2),
                            ),
                          ),
                        ])
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
