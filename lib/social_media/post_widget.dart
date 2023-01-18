import 'package:flutter/material.dart';
import 'package:skating_app/test.dart';
import '../objects/user.dart';
import '../objects/post.dart';
import 'comments.dart';

class PostWidget extends StatefulWidget {
  // Create HomePage Class
  const PostWidget({Key? key, required this.user, required this.index})
      : super(key: key); // Take 2 arguments optional key and title of post
  final User user; // Define title argument
  final int index; // Define title argument
  @override
  State<PostWidget> createState() => _PostWidget(); //Create state for widget
}

class _PostWidget extends State<PostWidget> {
  @override // Override existing build method
  Widget build(BuildContext context) {
    Post post = widget.user.getPosts()[widget.index];
    return Container(
      height: 315,
      padding: const EdgeInsets.all(0), // Add padding so doesn't touch edges
      color: const Color(0xFFFFE306), // For testing to highlight seperations
      child: Row(
        // Create a row
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Add Post image to one row and buttons to another
          Expanded(
            flex: 5,
            child: post.postImage, // Set child to post image
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
                      IconButton(
                          // Create Like Button
                          onPressed: () => print("Liked"),
                          icon: const Icon(Icons.thumb_up,
                              color: Color(0xffcfcfcf))),
                      IconButton(
                          // Create Comment Button
                          onPressed: () =>
                              // RootNavigator hides navbar
                              Navigator.of(context, rootNavigator: true).push(
                                  // Send to comments page
                                  MaterialPageRoute(
                                      builder: (context) => const Comments())),
                          icon: const Icon(
                            Icons.comment,
                            color: Color(0xffcfcfcf),
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
