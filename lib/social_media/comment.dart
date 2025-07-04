// Import necessary packages and files
import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:patinka/api/config/config.dart";
import "package:patinka/api/social.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/l10n/app_localizations.dart";
import "package:patinka/misc/default_profile.dart";
import "package:patinka/social_media/modals/comment_options_modal.dart";
import "package:patinka/social_media/user_reports/report_user.dart";
import "package:patinka/swatch.dart";
import "package:shimmer/shimmer.dart";
import "package:timeago/timeago.dart" as timeago;

// Comment Widget class for displaying individual comments
class Comment extends StatefulWidget {

  // Constructor for Comment widget
  const Comment({
    required this.index, required this.focus, required this.comment, super.key,
  });
  final Map<String, dynamic> comment;
  final int index;
  final FocusNode focus;

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
    SocialAPI.getUser(widget.comment["sender_id"]).then((final value) => mounted
        ? setState(() {
            user = value;
            avatar = value["avatar_id"];
          })
        : null);
    super.initState();
  }

  // Build method to create the UI of the Comment widget
  @override
  Widget build(final BuildContext context) => Container(
      // Container for each comment
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: swatch[401]!)),
        color: const Color.fromARGB(125, 0, 0, 0),
      ),
      padding: const EdgeInsets.all(4),
      child: TextButton(
        onPressed: () => commonLogger.i("Pressed"), // Handle comment press
        onLongPress: () {
          ModalBottomSheet.show(
            context: context,
            builder: (final context) => CommentOptionsBottomSheet(
              comment: widget.comment,
            ),
            startSize: 0.2,
            hideNavbar: false
          );
        },
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
                          placeholder: (final context, final url) => Shimmer.fromColors(
                            baseColor: shimmer["base"]!,
                            highlightColor: shimmer["highlight"]!,
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: swatch[900],
                            ),
                          ),
                          imageBuilder: (final context, final imageProvider) => Container(
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
                              ,
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

  // Helper method to create comment action buttons
  Widget _buildCommentActionButton({
    required final VoidCallback onPressed,
    required final String label,
  }) => Padding(
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
