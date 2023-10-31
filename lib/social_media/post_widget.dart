import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/api/social.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/profile/profile_page.dart';
import 'package:patinka/swatch.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';
import 'comments.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../api/config.dart';

class PostWidget extends StatefulWidget {
  // Create HomePage Class
  const PostWidget(
      {Key? key, required this.post, required this.index, required this.user})
      : super(key: key); // Take 2 arguments optional key and title of post
  final dynamic post; // Define title argument
  final int index; // Define title argument
  final Map<String, dynamic>? user;
  @override
  State<PostWidget> createState() => _PostWidget(); //Create state for widget
}

class _PostWidget extends State<PostWidget> {
  bool waiting = false;
  bool? likedState;
  @override
  void initState() {
    likedState = widget.post["liked"];
    super.initState();
  }

  Future<bool> handleLikePressed(bool isLiked) async {
    // Check if there is no ongoing process
    if (!waiting) {
      if (isLiked) {
        // If already liked, unlike the post
        try {
          waiting = true;
          // Call the unlikePost function with the post ID
          SocialAPI.unlikePost(widget.post["post_id"]).then((value) => {
                likedState!
                    ? mounted
                        ? setState(
                            () => likedState = false,
                          )
                        : null
                    : null,
                waiting = false
              });
          likedState = !isLiked;
          return !isLiked;
        } catch (e) {
          // If an error occurs while unliking, revert the liked state back to true
          return isLiked;
        }
      } else {
        // If not liked, like the post
        try {
          waiting = true;
          // Call the likePost function with the post ID
          SocialAPI.likePost(widget.post["post_id"]).then((value) => {
                !likedState!
                    ? mounted
                        ? setState(
                            () => likedState = true,
                          )
                        : null
                    : null,
                waiting = false
              });
          likedState = !isLiked;
          return !isLiked;
        } catch (e) {
          // If an error occurs while liking, revert the liked state back
          return isLiked;
        }
      }
    }
    return isLiked;
  }

  Future<bool> handleSavePressed(bool isSaved) async {
    return false;
  }

  Color selected = const Color.fromARGB(255, 136, 255, 0);
  Color unselected = const Color.fromARGB(255, 31, 207, 46);
  Color secondary = const Color.fromARGB(255, 15, 95, 5);

  @override // Override existing build method
  Widget build(BuildContext context) {
    commonLogger.v("Building ${widget.post['liked']}");
    String comments = widget.post['comment_count'] ?? "0";
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      false //widget.post["influencer"]
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0x77000000),
              ),
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(4),
              child: Text("Suggested Posts",
                  style: TextStyle(
                      color: swatch[401],
                      fontSize: 18,
                      fontWeight: FontWeight.bold)))
          : const SizedBox.shrink(),
      Expanded(
        child: Container(
          color: widget.post["description"] != null
              ? const Color(0xcc000000)
              : Colors.transparent,
          //height: 314,
          padding:
              const EdgeInsets.all(0), // Add padding so doesn't touch edges

          child: Row(
            // Create a row
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Add Post image to one row and buttons to another
              Expanded(
                flex: 5,
                child: ZoomOverlay(
                  modalBarrierColor: Colors.black12, // Optional
                  minScale: 0.5, // Optional
                  maxScale: 3.0, // Optional
                  animationCurve: Curves
                      .fastOutSlowIn, // Defaults to fastOutSlowIn which mimics IOS instagram behavior
                  animationDuration: const Duration(
                      milliseconds:
                          600), // Defaults to 100 Milliseconds. Recommended duration is 300 milliseconds for Curves.fastOutSlowIn
                  twoTouchOnly: true, // Defaults to false
                  child: CachedNetworkImage(
                    imageUrl: "${Config.uri}/image/${widget.post['image']}",
                    placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: shimmer["base"]!,
                        highlightColor: shimmer["highlight"]!,
                        child: Image.asset(
                          "assets/placeholders/1080.png",
                        )),
                    imageBuilder: (context, imageProvider) => Container(
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
                ), // Set child to post image
              ),
              Expanded(
                flex: 1, // Make 2x Bigger than sibling
                child: Container(
                  // Make container widget to use BoxDecoration
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        // Set background image of container to image
                        image: const AssetImage(
                            "assets/backgrounds/post_background.png"),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.3),
                            BlendMode.srcOver)), // Cover whole container
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8)),
                  ),
                  child: Column(
                      // Buttons below
                      children: [
                        Column(
                          children: [
                            LikeButton(
                              isLiked: likedState ?? widget.post["liked"],
                              onTap: (isLiked) => handleLikePressed(isLiked),
                              padding:
                                  const EdgeInsets.only(bottom: 0, top: 18),
                              countPostion: CountPostion.bottom,
                              size: 32.0,
                              circleColor:
                                  CircleColor(start: secondary, end: selected),
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
                              likeCount:
                                  int.parse(widget.post['total_likes'] ?? "0"),
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
                            ListTile(
                                title: IconButton(
                                  // Create Comment Button
                                  onPressed: () =>
                                      // RootNavigator hides navbar
                                      Navigator.of(context, rootNavigator: true)
                                          .push(
                                              // Send to comments page
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Comments(
                                                          post: widget
                                                              .post["post_id"],
                                                          user: widget.user))),
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
                            LikeButton(
                              //isLiked: likedState ?? widget.post["liked"],
                              onTap: (isSaved) => handleSavePressed(isSaved),
                              padding:
                                  const EdgeInsets.only(bottom: 0, top: 18),
                              countPostion: CountPostion.bottom,
                              size: 28.0,
                              circleColor:
                                  CircleColor(start: secondary, end: selected),
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
                          ],
                        ),
                        const Spacer(
                          flex: 1,
                        ),
                        Flexible(child: Avatar(user: widget.post["author_id"])),
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
      CaptionWrapper(post: widget.post)
    ]);
  }
}

class Avatar extends StatefulWidget {
  // Create HomePage Class
  const Avatar({Key? key, required this.user})
      : super(key: key); // Take 2 arguments optional key and title of post
  final String user; // Define title argument
  @override
  State<Avatar> createState() => _Avatar(); //Create state for widget
}

class _Avatar extends State<Avatar> {
  @override
  void initState() {
    SocialAPI.getUser(widget.user).then((userCache) => {
          if (mounted)
            {
              setState(() => {
                    image = userCache["avatar_id"],
                    profile = userCache["user_id"]
                  })
            }
        });
    super.initState();
  }

  String? image;
  String? profile;

  @override // Override existing build method
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () => profile != null // If the profile is not null
            ? Navigator.push(
                // Navigate to the ProfilePage with the user ID
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(
                          userId: profile!,
                          navbar: false,
                        )))
            : commonLogger
                .w("User not found"), // Otherwise, print "user not found"

        child: image == null
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
            : image != "default"
                ? CachedNetworkImage(
                    imageUrl: '${Config.uri}/image/thumbnail/$image',
                    placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: shimmer["base"]!,
                        highlightColor: shimmer["highlight"]!,
                        child: CircleAvatar(
                          // Create a circular avatar icon
                          radius: 36, // Set radius to 36
                          backgroundColor: swatch[900],
                        )),
                    imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            shape: BoxShape
                                .circle, // Set the shape of the container to a circle
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ))
                : CircleAvatar(
                    foregroundImage: const AssetImage("assets/icons/hand.png"),
                    // Create a circular avatar icon
                    radius: 36, // Set radius to 36
                    backgroundColor: swatch[900],
                  ));
  }
}

class CaptionWrapper extends StatefulWidget {
  // Create HomePage Class
  const CaptionWrapper({Key? key, required this.post})
      : super(key: key); // Take 2 arguments optional key and title of post
  final Map<String, dynamic> post; // Define title argument
  @override
  State<CaptionWrapper> createState() =>
      _CaptionWrapper(); //Create state for widget
}

class _CaptionWrapper extends State<CaptionWrapper> {
  bool collapsed = true;
  String? username;
  @override
  void initState() {
    SocialAPI.getUser(widget.post["author_id"]).then((user) => mounted
        ? setState(
            () => username = user["username"],
          )
        : null);

    super.initState();
  }

  @override // Override existing build method
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        collapsed = !collapsed;
      }),
      child: Caption(
          username: username,
          description: widget.post["description"],
          collapsed: collapsed),
    );
  }
}

class Caption extends StatelessWidget {
  final String? username;
  final String? description;
  final bool collapsed;

  const Caption(
      {super.key, this.username, this.description, required this.collapsed});

  @override // Override existing build method
  Widget build(BuildContext context) {
    if (username == null || description == null) {
      return Container(
        padding: const EdgeInsets.all(8),
      );
    }
    return GestureDetector(
        child: Container(
      width: double.infinity, // Make as big as parent allows
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(
          bottom: 24), // For testing to highlight seperations
      decoration: const BoxDecoration(
          color: Color(0xcc000000),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8))),
      child: RichText(
          overflow: collapsed ? TextOverflow.ellipsis : TextOverflow.visible,
          softWrap: true,
          text: TextSpan(children: <InlineSpan>[
            TextSpan(
                // padding: const EdgeInsets.only(right: 6),
                // child: Text(
                text: username,
                style: TextStyle(
                    color: swatch[801],
                    fontWeight: FontWeight.bold,
                    fontSize: 15)), //),
            const WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: SizedBox(width: 6)),
            // Flexible(

            //   child:
            TextSpan(
              text: description,
              style: TextStyle(color: swatch[801], fontSize: 15),

              //),
            )
          ])),
    ));
  }
}
