import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skating_app/api/social.dart';
import 'package:skating_app/objects/user.dart';
import 'package:skating_app/profile/profile_page.dart';
import 'package:skating_app/swatch.dart';
import 'package:skating_app/test.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';
import 'comments.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../api/config.dart';

class PostWidget extends StatefulWidget {
  // Create HomePage Class
  const PostWidget({Key? key, required this.post, required this.index})
      : super(key: key); // Take 2 arguments optional key and title of post
  final dynamic post; // Define title argument
  final int index; // Define title argument
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
          unlikePost(widget.post["_id"]).then((value) => {
                likedState!
                    ? setState(
                        () => likedState = false,
                      )
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
          likePost(widget.post["_id"]).then((value) => {
                likedState!
                    ? setState(
                        () => likedState = true,
                      )
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

  @override // Override existing build method
  Widget build(BuildContext context) {
    print("${Config.uri}/image/${widget.post['image']}");
    String comments = (widget.post['comment_count'] ?? 0).toString();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        color: widget.post["description"] != null
            ? const Color(0xcc000000)
            : Colors.transparent,
        height: 314,
        padding: const EdgeInsets.all(0), // Add padding so doesn't touch edges

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
                      baseColor: const Color(0x66000000),
                      highlightColor: const Color(0xff444444),
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
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.contain,
                ),
              ), // Set child to post image
            ),
            Expanded(
              flex: 1, // Make 2x Bigger than sibling
              child: Container(
                // Make container widget to use BoxDecoration
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      // Set background image of container to image
                      image:
                          AssetImage("assets/backgrounds/post_background.png"),
                      fit: BoxFit.cover), // Cover whole container
                  borderRadius: BorderRadius.only(
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
                            padding: const EdgeInsets.only(bottom: 0, top: 18),
                            countPostion: CountPostion.bottom,
                            size: 32.0,
                            circleColor: CircleColor(
                                start: swatch[401]!, end: swatch[201]!),
                            bubblesColor: BubblesColor(
                              dotPrimaryColor: swatch[101]!,
                              dotSecondaryColor: swatch[201]!,
                            ),
                            likeBuilder: (bool isLiked) {
                              return Icon(
                                Icons.thumb_up_alt,
                                color: isLiked
                                    ? swatch[501]
                                    : const Color(0xffcfcfcf),
                                size: 32.0,
                              );
                            },
                            likeCount: widget.post['like_count'],
                            countBuilder:
                                (int? count, bool isLiked, String text) {
                              var color = isLiked
                                  ? swatch[501]
                                  : const Color(0xffcfcfcf);
                              Widget result;
                              if (count == 0) {
                                result = Center(
                                    child: Text(
                                  "Like",
                                  style: TextStyle(color: color),
                                ));
                              } else {
                                result = Center(
                                    child: Text(
                                  text,
                                  style: TextStyle(color: color),
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
                                                builder: (context) => Comments(
                                                    post: widget.post["_id"]))),
                                icon: const Icon(
                                  Icons.comment,
                                  color: Color(0xffcfcfcf),
                                ),
                                padding: const EdgeInsets.only(top: 16),
                                constraints: const BoxConstraints(),
                              ),
                              subtitle: Text(
                                comments,
                                textAlign: TextAlign.center,
                                style:
                                    const TextStyle(color: Color(0xffcfcfcf)),
                              )),
                          IconButton(
                              // Create Save Button
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Testing())),
                              icon: const Icon(Icons.save,
                                  color: Color(0xffcfcfcf)))
                        ],
                      ),
                      const Spacer(
                        flex: 1,
                      ),
                      Flexible(child: Avatar(user: widget.post["author"])),
                    ]),
              ),
            ),
          ],
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
    getUserCache(widget.user).then((userCache) => {
          if (mounted)
            {
              setState(() =>
                  {image = userCache["avatar"], profile = userCache["_id"]})
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
            : print("user not found"), // Otherwise, print "user not found"

        child: image == null
            // If there is no cached user information or avatar image, use a default image
            ? CircleAvatar(
                radius: 36, // Set the radius of the circular avatar image
                child: ClipOval(
                  child: Image.asset("assets/placeholders/default.png"),
                ),
              )
            // If there is cached user information and an avatar image, use the cached image
            : CachedNetworkImage(
                imageUrl: '${Config.uri}/image/thumbnail/$image',
                placeholder: (context, url) => CircleAvatar(
                      radius: 36, // Set the radius of the circular avatar image
                      child: ClipOval(
                        child: Image.asset("assets/placeholders/default.png"),
                      ),
                    ),
                imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape
                            .circle, // Set the shape of the container to a circle
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                      ),
                    )));
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
    getUserCache(widget.post["author"]).then((user) => mounted
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
                text: username!,
                style: TextStyle(
                    color: swatch[801]!,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)), //),
            const WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: SizedBox(width: 6)),
            // Flexible(

            //   child:
            TextSpan(
              text: description!,
              style: TextStyle(color: swatch[801]!, fontSize: 15),

              //),
            )
          ])),
    ));
  }
}
