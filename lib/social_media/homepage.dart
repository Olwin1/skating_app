import 'package:flutter/material.dart';
import 'package:skating_app/objects/user.dart';
import 'post_widget.dart';

class HomePage extends StatelessWidget {
  // Create HomePage Class
  HomePage({Key? key, required this.title}) : super(key: key);
  final String title; // Define title argument
  final _scrollController = ScrollController();

  @override // Override the existing widget build method
  Widget build(BuildContext context) {
    User user = User("1"); // Create user object with id of 1
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          // Create a basic button
          child: const Image(
            // Set button to an image
            image: AssetImage("assets/placeholders/320x114.png"),
          ),
          onPressed: () {
            // When image pressed
            _scrollController.animateTo(0, //Scroll to top in 500ms
                duration: const Duration(milliseconds: 500),
                curve: Curves
                    .fastOutSlowIn); //Start scrolling fast then slow down when near top
          },
        ),
        title: Text(title),
        actions: [
          const Spacer(
            // Move button to far right of screen
            flex: 1,
          ),
          TextButton(
              onPressed: () => print("Private Messages"),
              child: Image.asset(
                  "assets/icons/navbar/message.png")) // Set Button To Message icon
        ],
      ),
      body: Center(
          child: ListView.separated(
        controller: _scrollController,
        // Create a list of post widgets
        padding: const EdgeInsets.all(
            8), // Add padding to list so doesn't overflow to sides of screen
        itemBuilder: (context, position) {
          // Function that will be looped to generate a widget
          return PostWidget(user: user, index: position);
        },
        separatorBuilder: (context, position) {
          // Function that will be looped in between each item
          return const SizedBox(
            // Create a seperator
            height: 20,
          );
        },
        itemCount: user
            .getPosts()
            .length, // Set count to the number of posts that there are
      )),
    );
  }
}
