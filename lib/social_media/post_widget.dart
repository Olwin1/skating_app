import 'package:flutter/material.dart';
import 'package:skating_app/api/social.dart';
import 'package:skating_app/objects/user.dart';
import 'package:skating_app/profile/profile_page.dart';
import 'package:skating_app/test.dart';
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
  bool liked = false;
  handleLikePressed() {
    if (liked) {
      // If already liked, unlike the post
      setState(
        () => liked = false,
      );
      try {
        unlikePost(widget
            .post["_id"]); // Call the unlikePost function with the post ID
      } catch (e) {
        // If an error occurs while unliking, revert the liked state back to true
        setState(
          () => liked = true,
        );
      }
    } else {
      // If not liked, like the post
      setState(
        () => liked = true,
      );
      try {
        likePost(
            widget.post["_id"]); // Call the likePost function with the post ID
      } catch (e) {
        // If an error occurs while liking, revert the liked state back to false
        setState(
          () => liked = false,
        );
      }
    }
  }

  @override
  void initState() {
    liked = widget.post["liked"];
    print("liked post is $liked");

    // TODO: implement initState
    super.initState();
  }

  @override // Override existing build method
  Widget build(BuildContext context) {
    //Post post = widget.user.getPosts()[widget.index];
    print("${Config.uri}/image/${widget.post['image']}");
    String likes = (liked
            ? (widget.post['like_count'] + 1 ?? 1)
            : (widget.post['like_count'] ?? 0))
        .toString();
    String comments = (widget.post['comment_count'] ?? 0).toString();
    return Container(
      height: 314,
      padding: const EdgeInsets.all(0), // Add padding so doesn't touch edges
      margin: const EdgeInsets.only(
          bottom: 24), // For testing to highlight seperations
      child: Row(
        // Create a row
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Add Post image to one row and buttons to another
          Expanded(
            flex: 5,
            child: CachedNetworkImage(
              imageUrl: "${Config.uri}/image/${widget.post['image']}",
              placeholder: (context, url) => const Center(
                child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Color(0xffcecece),
                    )),
              ),
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8)),
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.contain,
            ), // Set child to post image
          ),
          Expanded(
            flex: 1, // Make 2x Bigger than sibling
            child: Container(
              // Make container widget to use BoxDecoration
              decoration: const BoxDecoration(
                image: DecorationImage(
                    // Set background image of container to image
                    image: AssetImage("assets/backgrounds/post_background.png"),
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
                        ListTile(
                            title: IconButton(
                              // Create Like Button
                              onPressed: () => handleLikePressed(),
                              icon: const Icon(
                                Icons.thumb_up,
                                color: Color(0xffcfcfcf),
                              ),
                              padding: const EdgeInsets.only(top: 16),
                              constraints: const BoxConstraints(),
                            ),
                            subtitle: Text(
                              likes,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xffcfcfcf)),
                            )),
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
                              style: const TextStyle(color: Color(0xffcfcfcf)),
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
    );
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
                imageUrl: '${Config.uri}/image/$image',
                httpHeaders: const {"thumbnail": "a"},
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
