import 'package:flutter/material.dart';
import 'package:skating_app/objects/user.dart';
import 'package:skating_app/profile/edit_profile.dart';
import 'package:skating_app/profile/lists.dart';

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

// Define item type for popup menu
enum SampleItem { itemOne, itemTwo, itemThree }

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
        actions: const [
          // Define icon buttons
          OptionsMenu()
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

          GestureDetector(
              onTap: () => Navigator.push(
                  // Send to edit profile page
                  context,
                  MaterialPageRoute(builder: (context) => Lists(index: 0))),
              child: Column(children: const [Text("25"), Text("Followers")])),
          // Column to display the number of following
          const Spacer(),

          GestureDetector(
              onTap: () => Navigator.push(
                  // Send to edit profile page
                  context,
                  MaterialPageRoute(builder: (context) => Lists(index: 1))),
              child: Column(children: const [Text("25"), Text("Following")])),
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

class OptionsMenu extends StatefulWidget {
  // StatefulWidget that defines an options menu
  const OptionsMenu({super.key});

  @override
  State<OptionsMenu> createState() => _OptionsMenuState();
}

class _OptionsMenuState extends State<OptionsMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SampleItem>(
      // Offset to set the position of the menu relative to the button
      offset: const Offset(0, 64),
      // Callback function that will be called when a menu item is selected
      onSelected: (SampleItem item) {
        // In this case, it just prints "selected" to the console
        print("selected");
        if (item == SampleItem.itemOne) {
          // If item pressed is Edit Profile
          Navigator.push(
              // Send to edit profile page
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const EditProfile(title: "Edit Profile")));
        }
      },
      // Define the items in the menu using PopupMenuItem widgets
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
        // First menu item
        const PopupMenuItem<SampleItem>(
          // Value of the menu item, an instance of the SampleItem enumeration
          value: SampleItem.itemOne,
          // Text widget that displays the text for the menu item
          child: Text('Edit Profile'),
        ),
        // Second menu item
        const PopupMenuItem<SampleItem>(
          // Value of the menu item, an instance of the SampleItem enumeration
          value: SampleItem.itemTwo,
          // Text widget that displays the text for the menu item
          child: Text('Settings'),
        ),
        // Third menu item
        const PopupMenuItem<SampleItem>(
          // Value of the menu item, an instance of the SampleItem enumeration
          value: SampleItem.itemThree,
          // Text widget that displays the text for the menu item
          child: Text('Saved'),
        ),
      ],
    );
  }
}
