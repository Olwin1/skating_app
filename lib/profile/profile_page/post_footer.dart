import "package:flutter/material.dart";
import "package:like_button/like_button.dart";
import "package:patinka/social_media/comments.dart";
import "package:patinka/social_media/handle_buttons.dart";
import "package:patinka/social_media/post_widget.dart";

class PostFooter extends StatefulWidget {
  const PostFooter({
    required this.likedState, required this.savedState, required this.setSavedState, required this.post, required this.comments, required this.user, required this.backgroundColor, super.key
  });

  final bool likedState;
  final bool savedState;
  final Function(bool) setSavedState;
  final Map<String, dynamic>? post;
  final String comments;
  final Map<String, dynamic>? user;
  final Color backgroundColor;

  @override
  State<PostFooter> createState() => _PostFooterState();
}

class _PostFooterState extends State<PostFooter> {
  late bool likedState;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    likedState = widget.likedState;
    likeCount = widget.post?["like_count"] ?? 0;
  }

  Future<bool> handleLikePressedState(final bool isLiked) async {
    setState(() {
      likedState = isLiked;
      likeCount = likedState ? likeCount + 1 : likeCount - 1;
    });
    // Perform additional logic, e.g., API call, if necessary
    return !isLiked;
  }

  @override
  Widget build(final BuildContext context) => Container(
      padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      decoration: BoxDecoration(color: widget.backgroundColor, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8))),
      height: 73,
      width: 300,
      child: Row(
        children: [
          // Like button with animation
          LikeButton(
            isLiked: likedState,
            onTap: (final isLiked) => handleLikePressed(isLiked, handleLikePressedState, widget.post),
            padding: const EdgeInsets.only(bottom: 0, top: 12),
            countPostion: CountPostion.bottom,
            size: 28.0,
            circleColor: CircleColor(start: secondary, end: selected),
            bubblesColor: BubblesColor(
              dotPrimaryColor: unselected,
              dotSecondaryColor: secondary,
            ),
            likeBuilder: (final bool isLiked) => Icon(
                Icons.thumb_up,
                color: isLiked ? selected : unselected,
                size: 32.0,
              ),
            likeCount: likeCount,
            countBuilder: (final int? count, final bool isLiked, final String text) {
              final color = isLiked ? selected : unselected;
              return Center(
                child: Text(
                  count == 0 ? "Like" : text,
                  style: TextStyle(
                      color: color, fontSize: 16, fontWeight: FontWeight.w100),
                ),
              );
            },
          ),
          // Comment button
          Container(
            padding: const EdgeInsets.only(bottom: 29),
            height: 72,
            width: 72,
            child: ListTile(
              contentPadding: EdgeInsets.zero,//EdgeInsets.only(bottom: 16),
              title: IconButton(
                onPressed: () => Navigator.of(context).push(
                  // Navigate to comments page
                  PageRouteBuilder(
                    pageBuilder: (final context, final animation, final secondaryAnimation) =>
                        Comments(
                            post: widget.post?["post_id"], user: widget.user),
                    opaque: false,
                    transitionsBuilder:
                        (final context, final animation, final secondaryAnimation, final child) {
                      const begin = 0.0;
                      const end = 1.0;
                      final tween = Tween(begin: begin, end: end);
                      final fadeAnimation = tween.animate(animation);
                      return FadeTransition(
                        opacity: fadeAnimation,
                        child: child,
                      );
                    },
                  ),
                ),
                icon: Icon(
                  size: 26,
                  Icons.comment,
                  color: unselected,
                ),
                padding: const EdgeInsets.only(top: 14),
                constraints: const BoxConstraints(),
              ),
              subtitle: Text(
                widget.comments,
                textAlign: TextAlign.center,
                style: TextStyle(color: unselected),
              ),
            ),
          ),
          // Save button
          LikeButton(
            isLiked: widget.savedState,
            onTap: (final isSaved) =>
                handleSavePressed(isSaved, widget.setSavedState, widget.post),
            padding: const EdgeInsets.only(bottom: 0, top: 4),
            countPostion: CountPostion.bottom,
            size: 28.0,
            circleColor: CircleColor(start: secondary, end: selected),
            bubblesColor: BubblesColor(
              dotPrimaryColor: unselected,
              dotSecondaryColor: secondary,
            ),
            likeBuilder: (final bool isSaved) => Icon(
                Icons.save,
                color: isSaved ? selected : unselected,
                size: 28.0,
              ),
          ),
          const Spacer(),
          widget.user == null
              ? const SizedBox.shrink()
              : Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Avatar(
                      user: widget.user!["user_id"],
                    ),
                  ),
                ),
        ],
      ),
    );
}
