// Import necessary packages and files
import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:patinka/api/config.dart";
import "package:patinka/api/social.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/misc/default_profile.dart";
import "package:patinka/services/role.dart";
import "package:patinka/swatch.dart";
import "package:shimmer/shimmer.dart";
import "package:timeago/timeago.dart" as timeago;

// Message Widget class for displaying individual comments
class ReportMessage extends StatefulWidget {
  // Constructor for Message widget
  const ReportMessage(
      {required this.index,
      required this.focus,
      required this.message,
      required this.status,
      super.key});
  final Map<String, dynamic> message;
  final int index;
  final FocusNode focus;
  final Status status;

  @override
  State<ReportMessage> createState() =>
      _ReportMessageState(); // Create state for the Message widget
}

// State class for the Message widget
class _ReportMessageState extends State<ReportMessage> {
  Map<String, dynamic>? user;
  String? avatar;

  // Initialize state variables and fetch user information
  @override
  void initState() {
    SocialAPI.getUser(widget.message["sender_id"]).then((final value) => mounted
        ? setState(() {
            user = value;
            avatar = value["avatar_id"];
          })
        : null);
    super.initState();
  }

  // Build method to create the UI of the Message widget
  @override
  Widget build(final BuildContext context) => Container(
        // Container for each message
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: swatch[401]!)),
          color: const Color.fromARGB(125, 0, 0, 0),
        ),
        padding: const EdgeInsets.all(4),
        child: TextButton(
          onPressed: () => commonLogger.i("Pressed"), // Handle message press
          onLongPress: () =>
              commonLogger.i("longPress"), // Handle message long press
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display user avatar
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: user == null
                    ? Shimmer.fromColors(
                        // Shimmer effect for loading avatar
                        baseColor: shimmer["base"]!,
                        highlightColor: shimmer["highlight"]!,
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: swatch[900],
                        ),
                      )
                    : (avatar != "default" && avatar != null)
                        ? CachedNetworkImage(
                            imageUrl:
                                '${Config.uri}/image/thumbnail/${user!["avatar_id"]}',
                            placeholder: (final context, final url) =>
                                Shimmer.fromColors(
                              baseColor: shimmer["base"]!,
                              highlightColor: shimmer["highlight"]!,
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: swatch[900],
                              ),
                            ),
                            imageBuilder:
                                (final context, final imageProvider) =>
                                    Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        : const DefaultProfile(radius: 25),
              ),
              // Display user information and message content
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display user name and time since the message
                    RichText(
                      text: TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: user != null ? user!["username"] : "",
                            style: TextStyle(color: swatch[101]),
                          ),
                          const WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: SizedBox(width: 6),
                          ),
                          TextSpan(
                            text: timeago.format(
                                DateTime.parse(widget.message["timestamp"])),
                            style: TextStyle(color: swatch[501]),
                          ),
                        ],
                      ),
                    ),
                    // Display message content
                    Text(
                      widget.message["content"],
                      textAlign: TextAlign.start,
                      style: TextStyle(color: swatch[801]),
                    ),
                    const SizedBox(height: 20)
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
