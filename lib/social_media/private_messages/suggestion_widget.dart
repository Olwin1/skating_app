import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/common_logger.dart';
import '../../swatch.dart';
import '../../api/config.dart';
import 'private_message.dart';

// SuggestionListWidget class creates a stateful widget that displays a list of users
class SuggestionListWidget extends StatefulWidget {
  // Constructor for SuggestionListWidget
  const SuggestionListWidget(
      {Key? key, required this.user, required this.callback})
      : super(key: key);

  // Title for the widget
  final Map<String, dynamic> user;
  final Function callback;

  // Creates the state for the SuggestionListWidget
  @override
  State<SuggestionListWidget> createState() => _SuggestionListWidget();
}

// _SuggestionListWidget class is the state of the SuggestionListWidget
class _SuggestionListWidget extends State<SuggestionListWidget> {
  void handlePress() async {
    String currentUser = widget.user["user_id"];

    sendUser(currentUser);
  }

  void sendUser(String currentUser) {
    Navigator.push(
        // When button pressed
        context,
        MaterialPageRoute(
            builder: (context) => PrivateMessage(
                  // Add private message page to top of navigation stack
                  index: 1,
                  user: widget.user,
                  callback: widget.callback,
                  currentUser: currentUser,
                )));
  }

  // Builds the widget
  @override
  Widget build(BuildContext context) {
    // Returns a row with a CircleAvatar, a text widget, and a TextButton
    return GestureDetector(
        onTap: () => handlePress(),
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
                  child: widget.user["avatar_id"] == null
                      ? Shimmer.fromColors(
                          baseColor: shimmer["base"]!,
                          highlightColor: shimmer["highlight"]!,
                          child: CircleAvatar(
                            // Create a circular avatar icon
                            radius: 26, // Set radius to 36
                            backgroundColor: swatch[900],
                          ))
                      : widget.user["avatar_id"] != "default"
                          ? CachedNetworkImage(
                              imageUrl:
                                  '${Config.uri}/image/thumbnail/${widget.user["avatar_id"]}',
                              imageBuilder: (context, imageProvider) =>
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
                          : CircleAvatar(
                              foregroundImage:
                                  const AssetImage("assets/icons/hand.png"),
                              // Create a circular avatar icon
                              radius: 26, // Set radius to 36
                              backgroundColor: swatch[900],
                            ),
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
                TextButton(
                    onPressed: () => commonLogger.i("pressed"),
                    child: const Icon(Icons.chevron_right)),
                const Spacer()
              ],
            )));
  }
}
