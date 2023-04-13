import 'package:flutter/material.dart';
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
  @override // Override existing build method
  Widget build(BuildContext context) {
    //Post post = widget.user.getPosts()[widget.index];
    print("${Config.uri}/image/${widget.post['image']}");
    String likes = widget.post['like_count'] ?? "0";
    String comments = widget.post['comment_count'] ?? "0";
    return Container(
      height: 315,
      padding: const EdgeInsets.all(0), // Add padding so doesn't touch edges
      color: const Color(0xFFFFE306),
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
              errorWidget: (context, url, error) => const Icon(Icons.error),
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
              ),
              child: Column(
                // Buttons below
                children: [
                  Column(
                    children: [
                      ListTile(
                          title: IconButton(
                            // Create Like Button
                            onPressed: () => print(IconTheme.of(context).size),
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
                                Navigator.of(context, rootNavigator: true).push(
                                    // Send to comments page
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Comments())),
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
                          icon:
                              const Icon(Icons.save, color: Color(0xffcfcfcf)))
                    ],
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  Column(
                    // Create more options button seperately to add spacing between
                    children: [
                      IconButton(
                          onPressed: () => print("More Options"),
                          icon: const Icon(Icons.three_g_mobiledata,
                              color: Color(0xffcfcfcf))),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
