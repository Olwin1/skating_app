// Import necessary packages and files
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:patinka/api/config.dart';
import 'package:patinka/api/social.dart';
import 'package:patinka/misc/default_profile.dart';
import 'package:patinka/services/role.dart';
import 'package:patinka/swatch.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/common_logger.dart';
import 'package:timeago/timeago.dart' as timeago;

// Message Widget class for displaying individual comments
class ReportMessage extends StatefulWidget {
  final Map<String, dynamic> message;
  final int index;
  final FocusNode focus;
  final Status status;

  // Constructor for Message widget
  const ReportMessage({
    super.key,
    required this.index,
    required this.focus,
    required this.message,
    required this.status
  });

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
    SocialAPI.getUser(widget.message["sender_id"]).then((value) => mounted
        ? setState(() {
            user = value;
            avatar = value["avatar_id"];
          })
        : null);
    super.initState();
  }

  // Build method to create the UI of the Message widget
  @override
  Widget build(BuildContext context) {
    return Container(
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
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: shimmer["base"]!,
                            highlightColor: shimmer["highlight"]!,
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: swatch[900],
                            ),
                          ),
                          imageBuilder: (context, imageProvider) => Container(
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
                          text: timeago
                              .format(
                                  DateTime.parse(widget.message["timestamp"]))
                              .toString(),
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

  // Helper method to create message action buttons
  Widget _buildCommentActionButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    Widget txt = Text(
          label,
          textAlign: TextAlign.end,
          style: TextStyle(
            color: widget.status!=Status.closed?swatch[50]:Colors.grey,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: widget.status!=Status.closed?TextButton(
        onPressed: onPressed,
        child: txt,
      ):Padding(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16), child: txt),
    );
  }
}
