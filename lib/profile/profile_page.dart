import 'package:flutter/material.dart';
import 'package:skating_app/objects/user.dart';

// List of image urls
List<String> imageUrls = [
  'https://placeimg.com/640/480/animals',
  'https://placeimg.com/640/480/arch',
  'https://placeimg.com/640/480/nature',
  'https://placeimg.com/640/480/people',
  'https://placeimg.com/640/480/tech',
  'https://placeimg.com/640/480/animals',
  'https://placeimg.com/640/480/arch',
  'https://placeimg.com/640/480/nature',
  'https://placeimg.com/640/480/people',
  'https://placeimg.com/640/480/tech',
  'https://placeimg.com/640/480/nature',
  'https://placeimg.com/640/480/people',
  'https://placeimg.com/640/480/tech',
  'https://placeimg.com/640/480/animals',
  'https://placeimg.com/640/480/arch',
  'https://placeimg.com/640/480/nature',
  'https://placeimg.com/640/480/people',
];

// Creates a ProfilePage widget
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.title})
      : super(
            key:
                key); // Take 2 arguments: optional key and required title of the post
  final String title;

  @override
  // Create state for the widget
  State<ProfilePage> createState() => _ProfilePage();
}

// The state class for the ProfilePage widget
class _ProfilePage extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    // Create an instance of the User class with an id of '1'
    User user = User("1");

    return Scaffold(
      appBar: AppBar(
        // Create appBar widget
        title: const Text("username"), // Set title
        actions: [
          // Define icon buttons
          IconButton(
            onPressed: () => print("pressed"),
            icon: const Icon(Icons.menu),
          )
        ],
      ),
      // Basic list layout element
      body: ListView(shrinkWrap: true, children: [
        // Row to display the number of friends, followers, and following
        Row(children: [
          // Circle avatar
          const Padding(
            padding: EdgeInsets.all(8), // Add padding
            child: CircleAvatar(
              // Create a circular avatar icon
              radius: 36, // Set radius to 36
              backgroundImage: AssetImage(
                  "assets/placeholders/150.png"), // Set avatar to placeholder images
            ),
          ),
          const Spacer(),
          // Column to display the number of friends

          Column(children: const [Text("25"), Text("Friends")]),
          // Column to display the number of followers
          const Spacer(),

          Column(children: const [Text("25"), Text("Followers")]),
          // Column to display the number of following
          const Spacer(),

          Column(children: const [Text("25"), Text("Following")]),
          const Spacer(),
        ]),
        // Display the user's name
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text("John Doe"),
        ),
        // Display the user's bio
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text(
              textAlign: TextAlign.justify,
              """I'm baby actually taiyaki bruh, wolf lo-fi pmigas 
pickled. Sartorial tbh kinfolk paleo gochujang, hammock 
ascot cold-pressed small batch meditation crucifix blue bottle helvetica tofu."""),
        ),
        // Row with two text buttons
        Row(children: [
          // First text button
          Expanded(
            // Expand button to empty space
            child: TextButton(
                onPressed: () =>
                    print("pressed"), // Prints "pressed" when button is pressed
                child: const Text("Follow")),
          ), // Button text
          // Second text button
          Expanded(
            child: TextButton(
                // Expand button to empty space
                onPressed: () =>
                    print("pressed"), // Prints "pressed" when button is pressed
                child: const Text("Share Profile")),
          ), // Button text
          TextButton(
              onPressed: () => print("pressed"),
              child: const Icon(Icons.precision_manufacturing_outlined))
        ]),
        // Expanded grid view with images
        GridView.count(
          mainAxisSpacing: 2, // Space the children
          crossAxisSpacing: 2,
          shrinkWrap: true, // Shrink the grid view to fit its children
          physics: const ScrollPhysics(), // Scroll physics
          crossAxisCount: 3, // Number of columns
          childAspectRatio: 1.0, // Aspect ratio of children
          children: imageUrls
              .map(_createGridTileWidget)
              .toList(), // Map the list of image URLs to grid tiles
        ),
      ]),
    );
  }

  // Creates a grid tile widget from an image URL
  Widget _createGridTileWidget(String url) => Builder(
        builder: (context) => GestureDetector(
          onLongPress: () {
            // Code for long press event
            // _popupDialog = _createPopupDialog(url);
            //Overlay.of(context).insert(_popupDialog);
          },
          //onLongPressEnd: (details) => _popupDialog?.remove(),
          child: Image.network(url,
              fit: BoxFit.cover), // Display the image from the URL
        ),
      );
}
