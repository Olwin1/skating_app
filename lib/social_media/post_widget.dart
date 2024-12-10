import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:patinka/api/token.dart';
import 'package:patinka/misc/default_profile.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/api/social.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/profile/profile_page/profile_page.dart';
import 'package:patinka/swatch.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';
import 'comments.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../api/config.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'handle_buttons.dart';
import 'modals/post_options_modal.dart';
import 'user_reports/report_user.dart';

// Widget representing a post
class PostWidget extends StatefulWidget {
  const PostWidget({
    super.key,
    required this.post,
    required this.index,
    required this.user,
  });

  final dynamic post; // Post data
  final int index; // Index of the post
  final Map<String, dynamic>? user; // Current user data

  @override
  State<PostWidget> createState() => _PostWidget();
}

class _PostWidget extends State<PostWidget> {
  bool? likedState; // Flag for the liked state of the post
  bool? savedState; // Flag for the liked state of the post

  @override
  void initState() {
    likedState = widget.post["liked"]; // Set initial liked state
    savedState = widget.post["saved"];
    super.initState();
  }

  /// SET STATES
  void setLikedState(bool val) {
    if (!likedState!) {
      if (mounted) {
        setState(() => likedState = val);
      }
    }
  }

  void setSavedState(bool val) {
    if (savedState! && mounted) {
      setState(() => savedState = val);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract comment count from post data
    String comments = widget.post['comment_count'] ?? "0";

    // Widget structure for a post
    return GestureDetector(
        // Detects a long press gesture on the widget
        onLongPress: () {
          ModalBottomSheet.show(
            context: context,
            builder: (context) => PostOptionsBottomSheet(
              post: widget.post,
              savedState: savedState!,
              setSavedState: setSavedState,
            ),
            startSize: 0.3,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Container for overlay on post image
                  Container(
                    margin: const EdgeInsets.only(top: 320),
                    height: 60,
                    color: const Color(0xcc000000),
                  ),
                  Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.all(0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 5,
                          child: ZoomOverlay(
                            // Zoomable overlay for the post image
                            modalBarrierColor: Colors.black12,
                            minScale: 0.5,
                            maxScale: 3.0,
                            animationCurve: Curves.fastOutSlowIn,
                            animationDuration:
                                const Duration(milliseconds: 600),
                            twoTouchOnly: true,
                            child: CachedNetworkImage(
                              // Post image loaded from the network
                              imageUrl:
                                  "${Config.uri}/image/${widget.post['image']}",
                              placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: shimmer["base"]!,
                                  highlightColor: shimmer["highlight"]!,
                                  child: Image.asset(
                                      "assets/placeholders/1080.png")),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8)),
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        // Container for buttons and additional info
                        SizedBox(
                          width: 72,
                          height: double.maxFinite,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: const AssetImage(
                                      "assets/backgrounds/post_background.png"),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.3),
                                      BlendMode.srcOver)),
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8)),
                            ),
                            child: Column(
                              children: [
                                // Like button with animation
                                LikeButton(
                                  isLiked: likedState ?? widget.post["liked"],
                                  onTap: (isLiked) => handleLikePressed(
                                      isLiked, setLikedState, widget.post),
                                  padding:
                                      const EdgeInsets.only(bottom: 0, top: 18),
                                  countPostion: CountPostion.bottom,
                                  size: 32.0,
                                  circleColor: CircleColor(
                                      start: secondary, end: selected),
                                  bubblesColor: BubblesColor(
                                    dotPrimaryColor: unselected,
                                    dotSecondaryColor: secondary,
                                  ),
                                  likeBuilder: (bool isLiked) {
                                    return Icon(
                                      Icons.thumb_up,
                                      color: isLiked ? selected : unselected,
                                      size: 32.0,
                                    );
                                  },
                                  likeCount: int.parse(
                                      widget.post['total_likes'] ?? "0"),
                                  countBuilder:
                                      (int? count, bool isLiked, String text) {
                                    var color = isLiked ? selected : unselected;
                                    Widget result;
                                    if (count == 0) {
                                      result = Center(
                                          child: Text(
                                        "Like",
                                        style: TextStyle(
                                            color: color,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w100),
                                      ));
                                    } else {
                                      result = Center(
                                          child: Text(
                                        text,
                                        style: TextStyle(
                                            color: color,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w100),
                                        textAlign: TextAlign.center,
                                      ));
                                    }
                                    return result;
                                  },
                                ),
                                // Comment button
                                ListTile(
                                    title: IconButton(
                                      onPressed: () =>
                                          Navigator.of(context).push(
                                        // Navigate to comments page
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              Comments(
                                                  post: widget.post["post_id"],
                                                  user: widget.user),
                                          opaque: false,
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            const begin = 0.0;
                                            const end = 1.0;
                                            var tween =
                                                Tween(begin: begin, end: end);
                                            var fadeAnimation =
                                                tween.animate(animation);
                                            return FadeTransition(
                                              opacity: fadeAnimation,
                                              child: child,
                                            );
                                          },
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons.comment,
                                        color: unselected,
                                      ),
                                      padding: const EdgeInsets.only(top: 16),
                                      constraints: const BoxConstraints(),
                                    ),
                                    subtitle: Text(
                                      comments,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: unselected),
                                    )),
                                // Save button
                                LikeButton(
                                  isLiked: savedState ?? widget.post["saved"],
                                  onTap: (isSaved) => handleSavePressed(
                                      isSaved, setSavedState, widget.post),
                                  padding:
                                      const EdgeInsets.only(bottom: 0, top: 18),
                                  countPostion: CountPostion.bottom,
                                  size: 28.0,
                                  circleColor: CircleColor(
                                      start: secondary, end: selected),
                                  bubblesColor: BubblesColor(
                                    dotPrimaryColor: unselected,
                                    dotSecondaryColor: secondary,
                                  ),
                                  likeBuilder: (bool isSaved) {
                                    return Icon(
                                      Icons.save,
                                      color: isSaved ? selected : unselected,
                                      size: 28.0,
                                    );
                                  },
                                ),
                                const Spacer(),
                                widget.user == null
                                    ? const SizedBox.shrink()
                                    : Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        child: SizedBox(
                                            width: 56,
                                            height: 56,
                                            child: Avatar(
                                              user: widget.post!["author_id"],
                                            )))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Widget for displaying post caption
            CaptionWrapper(post: widget.post)
          ],
        ));
  }
}

// Widget for displaying user avatar
class Avatar extends StatefulWidget {
  const Avatar({
    super.key,
    required this.user,
  });

  final String user; // User ID

  @override
  State<Avatar> createState() => _Avatar();
}

class _Avatar extends State<Avatar> {
  @override
  void initState() {
    // Load user data forthe given user ID
    SocialAPI.getUser(widget.user).then((userCache) => {
          if (mounted)
            {
              setState(() {
                image = userCache["avatar_id"];
                profile = userCache["user_id"];
              })
            }
        });

    super.initState();
  }

  String? image;
  String? profile;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        onPressed: () => profile != null
            ? Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(
                          userId: profile!,
                          navbar: false,
                        )))
            : commonLogger.w("User not found"),
        child: image == null
            ? Shimmer.fromColors(
                baseColor: shimmer["base"]!,
                highlightColor: shimmer["highlight"]!,
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: swatch[900],
                ))
            : image != "default"
                ? CachedNetworkImage(
                    imageUrl: '${Config.uri}/image/thumbnail/$image',
                    placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: shimmer["base"]!,
                        highlightColor: shimmer["highlight"]!,
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: swatch[900],
                        )),
                    imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ))
                : const DefaultProfile(radius: 36));
  }
}

// Widget for displaying post caption and handling collapse/expand
class CaptionWrapper extends StatefulWidget {
  const CaptionWrapper({
    super.key,
    required this.post,
  });

  final Map<String, dynamic> post; // Post data

  @override
  State<CaptionWrapper> createState() => _CaptionWrapper();
}

class _CaptionWrapper extends State<CaptionWrapper> {
  bool collapsed = true; // Flag for collapsed/expanded state
  String? username;

  @override
  void initState() {
    // Load user data for the author of the post
    SocialAPI.getUser(widget.post["author_id"]).then(
        (user) => mounted ? setState(() => username = user["username"]) : null);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        collapsed = !collapsed;
      }),
      child: Caption(
          username: username,
          description: widget.post["description"],
          timestamp: DateTime.parse(widget.post["timestamp"]),
          collapsed: collapsed),
    );
  }
}

// Widget for displaying post caption
class Caption extends StatelessWidget {
  final String? username;
  final String? description;
  final bool collapsed;
  final DateTime timestamp;

  const Caption({
    super.key,
    this.username,
    this.description,
    required this.collapsed,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    // Format the timestamp as relative time
    String timeAgo = timeago.format(timestamp);
    if (username == null || description == null) {
      // If username or description is null, return an empty container
      return Container(
        padding: const EdgeInsets.all(8),
      );
    }
    // Return a container with styled text for post caption
    return GestureDetector(
        child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: const BoxDecoration(
          color: Color(0xcc000000),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8))),
      child: RichText(
          overflow: collapsed ? TextOverflow.ellipsis : TextOverflow.visible,
          softWrap: true,
          text: TextSpan(children: <InlineSpan>[
            TextSpan(
                text: username,
                style: TextStyle(
                    color: swatch[801],
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            const WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: SizedBox(width: 6)),
            TextSpan(
              text: timeAgo,
              style: TextStyle(
                  color: swatch[801],
                  fontSize: 14,
                  fontStyle: FontStyle.italic),
            ),
            const WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: SizedBox(width: 6)),
            TextSpan(
              text: description,
              style: TextStyle(color: swatch[801], fontSize: 15),
            ),
          ])),
    ));
  }
}
