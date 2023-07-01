import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:provider/provider.dart';
import 'package:skating_app/api/social.dart';
import 'package:skating_app/objects/user.dart';
import 'package:skating_app/profile/edit_profile.dart';
import 'package:skating_app/profile/follow_button.dart';
import 'package:skating_app/profile/lists.dart';
import 'package:skating_app/profile/settings/settings.dart';

import '../api/config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../current_tab.dart';
import '../swatch.dart';

// Define item type for popup menu
enum SampleItem { itemOne, itemTwo, itemThree }

// Define a new StatelessWidget called ProfilePage
class ProfilePage extends StatelessWidget {
  final String userId;
  final bool navbar;

  // Constructor for ProfilePage, which calls the constructor for its superclass (StatelessWidget)
  const ProfilePage({super.key, required this.userId, required this.navbar});

  // Override the build method of StatelessWidget to return a Consumer widget
  @override
  Widget build(BuildContext context) {
    // Use the Consumer widget to listen for changes to the CurrentPage object
    return navbar
        ? Consumer<CurrentPage>(
            builder: (context, currentPage, widget) =>
                // If the CurrentPage's tab value is 4 (The profile page), return a Profile widget
                currentPage.tab == 4
                    ? Profile(userId: userId)
                    :
                    // Otherwise, return an empty SizedBox widget
                    const SizedBox.shrink(),
          )
        : Profile(userId: userId);
  }
}

// Creates a ProfilePage widget
class Profile extends StatefulWidget {
  const Profile({Key? key, required this.userId})
      : super(
            key:
                key); // Take 2 arguments: optional key and required title of the post
  final String userId;

  @override
  // Create state for the widget
  State<Profile> createState() => _Profile();
}

// The state class for the ProfilePage widget
class _Profile extends State<Profile> {
  Map<String, dynamic>? user;
  @override
  void initState() {
    getUserCache(widget.userId).then((value) => {
          if (mounted) {setState(() => user = value)}
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Create appBar widget
          title: Text(user?["username"] ??
              AppLocalizations.of(context)!.username), // Set title
          actions: widget.userId == "0"
              ? [
                  // Define icon buttons
                  OptionsMenu(
                    user: user,
                  )
                ]
              : null,
        ),
        // Basic list layout element
        body: Stack(children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: const AssetImage("assets/backgrounds/graffiti.png"),
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomLeft,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5), BlendMode.srcOver)),
            ),
          ),
          ListView(shrinkWrap: true, children: [
            // Row to display the number of friends, followers, and following
            Row(children: [
              // Circle avatar
              Padding(
                padding: const EdgeInsets.all(8), // Add padding
                child: user?["avatar"] == null
                    ? const CircleAvatar(
                        // Create a circular avatar icon
                        radius: 36, // Set radius to 36
                        backgroundImage: AssetImage(
                            "assets/placeholders/default.png"), // Set avatar to placeholder images
                      )
                    : CachedNetworkImage(
                        imageUrl: '${Config.uri}/image/${user!["avatar"]}',
                        imageBuilder: (context, imageProvider) => Container(
                          height: 72,
                          width: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape
                                .circle, // Set the shape of the container to a circle
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                        httpHeaders: const {"thumbnail": "true"},
                      ),
              ),
              // Column to display the number of friends

              ConnectionLists(
                user: user,
              ),
            ]),
            // Display the user's name
            Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(125, 0, 0, 0),
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.all(8),
              child: Text(
                  user?["username"] ?? AppLocalizations.of(context)!.username,
                  style: TextStyle(color: swatch[601])),
            ),
            // Display the user's bio
            Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(125, 0, 0, 0),
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.all(8),
              child: Text(
                  textAlign: TextAlign.justify,
                  (user?["description"] ?? "").toString(),
                  style: TextStyle(color: swatch[801])),
            ),
            // Row with two text buttons
            Row(children: [
              // First text button
              Expanded(
                  // Expand button to empty space
                  child: FollowButton(
                user: widget.userId,
                userObj: user,
              )), // Button text
              // Second text button
              Expanded(
                  child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                    color: Color.fromARGB(125, 0, 0, 0),
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: TextButton(
                    // Expand button to empty space
                    onPressed: () => print(
                        "pressed"), // Prints "pressed" when button is pressed
                    child: Text(AppLocalizations.of(context)!.shareProfile,
                        style: TextStyle(color: swatch[401]))),
              )), // Button text
              Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(125, 0, 0, 0),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: TextButton(
                      onPressed: () => print("pressed"),
                      child: Icon(
                        Icons.precision_manufacturing_outlined,
                        color: swatch[401],
                      )))
            ]),
            // Expanded grid view with images
            UserPostsList(user: user)
          ]),
        ]));
  }
}

class OptionsMenu extends StatefulWidget {
  final Map<String, dynamic>? user;

  // StatefulWidget that defines an options menu
  const OptionsMenu({super.key, required this.user});

  @override
  State<OptionsMenu> createState() => _OptionsMenuState();
}

class _OptionsMenuState extends State<OptionsMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SampleItem>(
      color: swatch[500],
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
                  builder: (context) => EditProfile(
                        user: widget.user,
                      )));
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
        PopupMenuItem<SampleItem>(
          // Value of the menu item, an instance of the SampleItem enumeration
          value: SampleItem.itemOne,
          // Text widget that displays the text for the menu item
          child: Text(AppLocalizations.of(context)!.editProfile,
              style: TextStyle(color: swatch[801])),
        ),
        // Second menu item
        PopupMenuItem<SampleItem>(
          // Value of the menu item, an instance of the SampleItem enumeration
          value: SampleItem.itemTwo,
          // Text widget that displays the text for the menu item
          child: Text(AppLocalizations.of(context)!.settings,
              style: TextStyle(color: swatch[801])),
        ),
        // Third menu item
        PopupMenuItem<SampleItem>(
          // Value of the menu item, an instance of the SampleItem enumeration
          value: SampleItem.itemThree,
          // Text widget that displays the text for the menu item
          child: Text(AppLocalizations.of(context)!.saved,
              style: TextStyle(color: swatch[801])),
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
          child: InstaImageViewer(
            child: CachedNetworkImage(
              imageUrl: '${Config.uri}/image/${post["image"]}',
              httpHeaders: const {"thumbnail": "true"},
              fit: BoxFit.cover,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      8), // Set the shape of the container to a circle
                  image: DecorationImage(
                      image: imageProvider, fit: BoxFit.contain),
                ),
              ),
            ), // Display the image from the URL
          )),
    );

class UserPostsList extends StatefulWidget {
  final Map<String, dynamic>? user;
  const UserPostsList({super.key, required this.user});

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
      final page = await getUserPosts(widget.user?["_id"], pageKey);

      // Determine if this is the last page of posts
      final isLastPage = page.length < _pageSize;

      if (isLastPage && mounted) {
        // If this is the last page of posts, append it to the PagingController as the final page
        _pagingController.appendLastPage(page);
      } else if (mounted) {
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
    return widget.user != null
        ? PagedGridView<int, Map<String, dynamic>>(
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
              noItemsFoundIndicatorBuilder: (context) => Center(
                // Localized text string that will be displayed when no items are found
                child: Text(
                  AppLocalizations.of(context)!.noPostsFound,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: swatch[900]),
                ),
              ),
              // Specify how to build each grid tile
              itemBuilder: (context, item, index) =>
                  _createGridTileWidget(item),
            ),
          )
        : const SizedBox.shrink();
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

class ConnectionLists extends StatelessWidget {
  final Map<String, dynamic>? user;

  const ConnectionLists({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: const Color.fromARGB(125, 0, 0, 0),
                borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Spacer(),
              Column(children: [
                Text((user?["friends_count"] ?? 0).toString(),
                    style: TextStyle(color: swatch[601])),
                Text(AppLocalizations.of(context)!.friends,
                    style: TextStyle(color: swatch[701]))
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
                    Text((user?["followers_count"] ?? 0).toString(),
                        style: TextStyle(color: swatch[601])),
                    Text(AppLocalizations.of(context)!.followers,
                        style: TextStyle(color: swatch[701]))
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
                    Text((user?["following_count"] ?? 0).toString(),
                        style: TextStyle(color: swatch[601])),
                    Text(AppLocalizations.of(context)!.following,
                        style: TextStyle(color: swatch[701]))
                  ])),
              const Spacer(),
            ])));
  }
}
