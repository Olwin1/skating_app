// Import necessary packages and files
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/common_logger.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../api/config.dart';
import '../api/social.dart';
import '../misc/default_profile.dart';
import '../swatch.dart';

// Comment Widget class for displaying individual comments
class Comment extends StatefulWidget {
  final Map<String, dynamic> comment;
  final int index;
  final FocusNode focus;

  // Constructor for Comment widget
  const Comment({
    super.key,
    required this.index,
    required this.focus,
    required this.comment,
  });

  @override
  State<Comment> createState() =>
      _CommentState(); // Create state for the Comment widget
}

// State class for the Comment widget
class _CommentState extends State<Comment> {
  Map<String, dynamic>? user;
  String? avatar;

  // Initialize state variables and fetch user information
  @override
  void initState() {
    SocialAPI.getUser(widget.comment["sender_id"]).then((value) => mounted
        ? setState(() {
            user = value;
            avatar = value["avatar_id"];
          })
        : null);
    super.initState();
  }

  // Build method to create the UI of the Comment widget
  @override
  Widget build(BuildContext context) {
    return Container(
      // Container for each comment
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: swatch[401]!)),
        color: const Color.fromARGB(125, 0, 0, 0),
      ),
      padding: const EdgeInsets.all(4),
      child: TextButton(
        onPressed: () => commonLogger.i("Pressed"), // Handle comment press
        onLongPress: () =>
            commonLogger.i("longPress"), // Handle comment long press
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
            // Display user information and comment content
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display user name and time since the comment
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
                                  DateTime.parse(widget.comment["timestamp"]))
                              .toString(),
                          style: TextStyle(color: swatch[501]),
                        ),
                      ],
                    ),
                  ),
                  // Display comment content
                  Text(
                    widget.comment["content"],
                    textAlign: TextAlign.start,
                    style: TextStyle(color: swatch[801]),
                  ),
                  // Display comment actions (e.g., reply, like, dislike)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildCommentActionButton(
                        onPressed: () => widget.focus.requestFocus(),
                        label: AppLocalizations.of(context)!.reply,
                      ),
                      _buildCommentActionButton(
                        onPressed: () {},
                        label: AppLocalizations.of(context)!.like,
                      ),
                      _buildCommentActionButton(
                        onPressed: () {},
                        label: AppLocalizations.of(context)!.dislike,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create comment action buttons
  Widget _buildCommentActionButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          label,
          textAlign: TextAlign.end,
          style: TextStyle(
            color: swatch[50],
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
