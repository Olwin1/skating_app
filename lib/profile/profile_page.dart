import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:skating_app/api/social.dart';
import 'package:skating_app/objects/user.dart';
import 'package:skating_app/profile/edit_profile.dart';
import 'package:skating_app/profile/lists.dart';
import 'package:skating_app/profile/settings/settings.dart';

import '../api/config.dart';

// Define item type for popup menu
enum SampleItem { itemOne, itemTwo, itemThree }

// Creates a ProfilePage widget
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.userId})
      : super(
            key:
                key); // Take 2 arguments: optional key and required title of the post
  final String userId;

  @override
  // Create state for the widget
  State<ProfilePage> createState() => _ProfilePage();
}

// The state class for the ProfilePage widget
class _ProfilePage extends State<ProfilePage> {
  Map<String, dynamic>? user;
  @override
  void initState() {
    getUserCache(widget.userId).then((value) => {setState(() => user = value)});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

          Column(children: [
            Text((user?["friends_count"] ?? 0).toString()),
            const Text("Friends")
          ]),
          // Column to display the number of followers
          const Spacer(),

          GestureDetector(
              onTap: () => Navigator.push(
                  // Send to edit profile page
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Lists(index: 0))),
              child: Column(children: [
                Text((user?["followers_count"] ?? 0).toString()),
                const Text("Followers")
              ])),
          // Column to display the number of following
          const Spacer(),

          GestureDetector(
              onTap: () => Navigator.push(
                  // Send to edit profile page
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Lists(index: 1))),
              child: Column(children: [
                Text((user?["following_count"] ?? 0).toString()),
                const Text("Following")
              ])),
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
        const UserPostsList()
      ]),
    );
  }
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
        if (item == SampleItem.itemTwo) {
          // If item pressed is Settings
          Navigator.push(
              // Send to settings page
              context,
              MaterialPageRoute(
                  builder: (context) => const Settings(
                        item: 0,
                      )));
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

// Creates a grid tile widget from an image URL
Widget _createGridTileWidget(Map<String, dynamic> post) => Builder(
      builder: (context) => GestureDetector(
        onLongPress: () {
          // Code for long press event
          // _popupDialog = _createPopupDialog(url);
          //Overlay.of(context).insert(_popupDialog);
        },
        //onLongPressEnd: (details) => _popupDialog?.remove(),
        child: CachedNetworkImage(
            imageUrl: '${Config.uri}/image/${post["image"]}',
            fit: BoxFit.cover), // Display the image from the URL
      ),
    );

class UserPostsList extends StatefulWidget {
  const UserPostsList({super.key});

  @override
  State<UserPostsList> createState() => _UserPostsListState();
}

class _UserPostsListState extends State<UserPostsList> {
  // Define the page size used for pagination
  static const _pageSize = 20;

  // Create a PagingController to manage pagination
  final PagingController<int, Map<String, dynamic>> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    // Add a listener to the PagingController that fetches the next page when requested
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      // Fetch the next page of posts from the user's account
      final page = await getUserPosts(pageKey);

      // Determine if this is the last page of posts
      final isLastPage = page.length < _pageSize;

      if (isLastPage) {
        // If this is the last page of posts, append it to the PagingController as the final page
        _pagingController.appendLastPage(page);
      } else {
        // If there are more pages of posts, append the current page to the PagingController
        // and specify the key for the next page
        final nextPageKey = pageKey += 1;
        _pagingController.appendPage(page, nextPageKey);
      }
    } catch (error) {
      // If an error occurs while fetching a page, set the PagingController's error state
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedGridView<int, Map<String, dynamic>>(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      pagingController: _pagingController,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        // Specify the properties for the grid tiles
        childAspectRatio: 1,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        maxCrossAxisExtent: MediaQuery.of(context).size.width / 3,
      ),
      builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
        // Specify how to build each grid tile
        itemBuilder: (context, item, index) => _createGridTileWidget(item),
      ),
    );
  }

  @override
  void dispose() {
    try {
      // Dispose of the PagingController when the state object is disposed
      _pagingController.dispose();
    } catch (e) {
      print(e);
    }
    super.dispose();
  }
}
