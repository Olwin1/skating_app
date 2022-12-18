import 'package:flutter/material.dart';
import 'package:skating_app/objects/user.dart';
import 'post_widget.dart';

class HomePage extends StatelessWidget {
  // Create HomePage Class
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title; // Define title argument

  @override // Override the existing widget build method
  Widget build(BuildContext context) {
    User user = User("1"); // Create user object with id of 1
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
          child: ListView.separated(
        // Create a list of post widgets
        padding: const EdgeInsets.all(
            8), // Add padding to list so doesn't overflow to sides of screen
        itemBuilder: (context, position) {
          // Function that will be looped to generate a widget
          return PostWidget(title: user.posts[position].title);
        },
        separatorBuilder: (context, position) {
          // Function that will be looped in between each item
          return const SizedBox(
            // Create a seperator
            height: 20,
          );
        },
        itemCount: 3, // Set count to the number of posts that there are
      )),
    );
  }
}
