import 'package:flutter/material.dart';

class FriendActivity extends StatefulWidget {
  // Create FriendActivity widget
  const FriendActivity({Key? key, required this.searchOpened})
      : super(key: key); // Take 2 arguments optional key and title of post
  final bool searchOpened;
  @override
  State<FriendActivity> createState() =>
      _FriendActivity(); //Create state for widget
}

class _FriendActivity extends State<FriendActivity> {
  @override // Override existing build method
  Widget build(BuildContext context) {
    return widget.searchOpened
        ? Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 32),
            height: 136,
            width: 600,
            child: ListView(
              // This next line does the trick.
              scrollDirection: Axis.horizontal,
              children: const <Widget>[
                FriendActivityProfile(),
                FriendActivityProfile(),
                FriendActivityProfile(),
                FriendActivityProfile(),
                FriendActivityProfile(),
                FriendActivityProfile(),
                FriendActivityProfile(),
                FriendActivityProfile(),
                FriendActivityProfile(),
                FriendActivityProfile(),
              ],
            ))
        : Container();
  }
}

class FriendActivityProfile extends StatefulWidget {
  // Create FriendActivity widget
  const FriendActivityProfile({Key? key})
      : super(key: key); // Take 2 arguments optional key and title of post
  @override
  State<FriendActivityProfile> createState() =>
      _FriendActivityProfile(); //Create state for widget
}

class _FriendActivityProfile extends State<FriendActivityProfile> {
  @override // Override existing build method
  Widget build(BuildContext context) {
    return Column(children: [
      TextButton(
        onPressed: () => print("Pressdd user icon"),
        child: const CircleAvatar(
          // Create a circular avatar icon
          radius: 36, //Set radius to 36
          backgroundImage: AssetImage(
              "assets/placeholders/150.png"), // Set avatar to placeholder images
        ),
      ),
      const Text("Username") // Set username
    ]);
  }
}
