import 'package:flutter/material.dart';
import 'package:skating_app/objects/user.dart';
import 'package:skating_app/social_media/private_messages/private_message_list.dart';
import 'post_widget.dart';

class HomePage extends StatelessWidget {
  // Create HomePage Class
  HomePage({Key? key}) : super(key: key);
  final _scrollController = ScrollController();

  @override // Override the existing widget build method
  Widget build(BuildContext context) {
    User user = User("1"); // Create user object with id of 1
    return Scaffold(
      appBar: AppBar(
        //systemOverlayStyle:
        //    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
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
        title: const Text("Home"),
        backgroundColor: const Color.fromARGB(255, 185, 177, 102),
        actions: [
          const Spacer(
            // Move button to far right of screen
            flex: 1,
          ),
          TextButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PrivateMessageList(
                            user: user,
                            index: 1,
                          ))),
              child: Image.asset(
                  "assets/icons/message.png")) // Set Button To Message icon
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
