import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay/flutter_overlay.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:patinka/profile/saved_posts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/api/messages.dart';
import 'package:patinka/api/social.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/profile/edit_profile.dart';
import 'package:patinka/profile/follow_button.dart';
import 'package:patinka/profile/friend_icon_button.dart';
import 'package:patinka/profile/friends_list.dart';
import 'package:patinka/profile/lists.dart';
import 'package:patinka/profile/settings/settings.dart';

import '../api/config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../components/list_error.dart';
import '../current_tab.dart';
import '../misc/default_profile.dart';
import '../swatch.dart';

// Define item type for popup menu
enum DropdownPage { editProfile, settings, saved }

String? currentImage;

// Define a new StatelessWidget called ProfilePage
class ProfilePage extends StatelessWidget {
  final String userId;
  final bool navbar;
  final bool? friend;

  // Constructor for ProfilePage, which calls the constructor for its superclass (StatelessWidget)
  const ProfilePage(
      {super.key, required this.userId, required this.navbar, this.friend});

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
        : Profile(
            userId: userId,
            friend: friend,
          );
  }
}

// Creates a ProfilePage widget
class Profile extends StatefulWidget {
  const Profile(
      {super.key,
      required this.userId,
      this.user,
      this.friend}); // Take 2 arguments: optional key and required title of the post
  final String userId;
  final Map<String, dynamic>? user;
  final bool? friend;

  @override
  // Create state for the widget
  State<Profile> createState() => _Profile();
}

// The state class for the ProfilePage widget
class _Profile extends State<Profile> {
  void _show() {
    HiOverlay.show(
      context,
      child: _dialog(),
    ).then((value) {
      commonLogger.t('Recieved value: $value');
    });
  }

  GestureDetector _dialog() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context, 'close');
      },
      child: currentImage != null
          ? Container(
              color: const Color(0x55000000),
              padding: const EdgeInsets.all(4),
              child: CachedNetworkImage(
                imageUrl: '${Config.uri}/image/$currentImage',
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        8), // Set the shape of the container to a circle
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.contain),
                  ),
                ),
              ))
          : const SizedBox.shrink(),
    );
  }

  Map<String, dynamic>? user;
  String? avatar;
  @override
  void initState() {
    if (widget.user == null) {
      SocialAPI.getUser(widget.userId).then((value) => {
            if (mounted)
              {
                setState(() {
                  user = value;
                  avatar = value["avatar_id"];
                })
              }
          });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user != null) {
      user = widget.user;
    }
    return Scaffold(
      backgroundColor: const Color(0x33000000),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: swatch[701]),
        elevation: 8,
        shadowColor: Colors.green.shade900,
        backgroundColor: Config.appbarColour,
        foregroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        // Create appBar widget
        title: user?["username"] != null
            ? Text(
                user?["username"] ?? AppLocalizations.of(context)!.username,
                style: TextStyle(color: swatch[801]),
              )
            : Shimmer.fromColors(
                baseColor: shimmer["base"]!,
                highlightColor: shimmer["highlight"]!,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 24.0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                )), // Set title
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
      body: ListView(shrinkWrap: true, children: [
        // Row to display the number of friends, followers, and following
        Row(children: [
          // Circle avatar
          Padding(
            padding: const EdgeInsets.all(8), // Add padding
            child: avatar == null
                ? Shimmer.fromColors(
                    baseColor: shimmer["base"]!,
                    highlightColor: shimmer["highlight"]!,
                    child: Shimmer.fromColors(
                        baseColor: shimmer["base"]!,
                        highlightColor: shimmer["highlight"]!,
                        child: CircleAvatar(
                          // Create a circular avatar icon
                          radius: 36, // Set radius to 36
                          backgroundColor: swatch[900],
                        )))
                : avatar != "default"
                    ? CachedNetworkImage(
                        placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: shimmer["base"]!,
                            highlightColor: shimmer["highlight"]!,
                            child: CircleAvatar(
                              // Create a circular avatar icon
                              radius: 36, // Set radius to 36
                              backgroundColor: swatch[900],
                            )),
                        imageUrl: '${Config.uri}/image/${user!["avatar_id"]}',
                        imageBuilder: (context, imageProvider) => Container(
                          height: 72,
                          width: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape
                                .circle, // Set the shape of the container to a circle
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.contain),
                          ),
                        ),
                        httpHeaders: const {"thumbnail": "true"},
                      )
                    : const DefaultProfile(radius: 36),
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
          child: Text(user?["username"] ?? "",
              style: TextStyle(color: swatch[601])),
        ),
        // Display the user's bio
        (user != null && user!["description"] != null)
            ? Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: const Color.fromARGB(125, 0, 0, 0),
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(8),
                child: Text(
                    textAlign: TextAlign.justify,
                    (user!["description"]).toString(),
                    style: TextStyle(color: swatch[801])),
              )
            : const SizedBox.shrink(),
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
                onPressed: () => commonLogger
                    .i("pressed"), // Prints "pressed" when button is pressed
                child: Text(AppLocalizations.of(context)!.shareProfile,
                    style: TextStyle(color: swatch[401]))),
          )), // Button text
          FriendIconButton(user: user, friend: widget.friend)
        ]),
        // Expanded grid view with images
        UserPostsList(user: user, imageViewerController: _show)
      ]),
    );
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
    return PopupMenuButton<DropdownPage>(
      color: const Color(0x66000000),
      icon: Icon(
        Icons.more_vert,
        color: swatch[601],
      ),
      // Offset to set the position of the menu relative to the button
      offset: const Offset(0, 64),
      // Callback function that will be called when a menu item is selected
      onSelected: (DropdownPage item) {
        // In this case, it just prints "selected" to the console
        commonLogger.i("selected");
        if (item == DropdownPage.editProfile) {
          // If item pressed is Edit Profile
          Navigator.push(
            // Send to edit profile page
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  EditProfile(
                user: widget.user,
              ),
              opaque: false,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = 0.0;
                const end = 1.0;
                var tween = Tween(begin: begin, end: end);
                var fadeAnimation = tween.animate(animation);
                return FadeTransition(
                  opacity: fadeAnimation,
                  child: child,
                );
              },
            ),
          );
        }
        if (item == DropdownPage.settings) {
          // If item pressed is Settings
          Navigator.push(
            // Send to settings page
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  Settings(user: widget.user),
              opaque: false,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = 0.0;
                const end = 1.0;
                var tween = Tween(begin: begin, end: end);
                var fadeAnimation = tween.animate(animation);
                return FadeTransition(
                  opacity: fadeAnimation,
                  child: child,
                );
              },
            ),
          );
        }
        if (item == DropdownPage.saved) {
          // If item pressed is Settings
          Navigator.push(
            // Send to settings page
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const SavedPosts(),
              opaque: false,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = 0.0;
                const end = 1.0;
                var tween = Tween(begin: begin, end: end);
                var fadeAnimation = tween.animate(animation);
                return FadeTransition(
                  opacity: fadeAnimation,
                  child: child,
                );
              },
            ),
          );
        }
      },
      // Define the items in the menu using PopupMenuItem widgets
      itemBuilder: (BuildContext context) => <PopupMenuEntry<DropdownPage>>[
        // First menu item
        PopupMenuItem<DropdownPage>(
          // Value of the menu item, an instance of the DropdownPage enumeration
          value: DropdownPage.editProfile,
          // Text widget that displays the text for the menu item
          child: Text(AppLocalizations.of(context)!.editProfile,
              style: TextStyle(color: swatch[801])),
        ),
        // Second menu item
        PopupMenuItem<DropdownPage>(
          // Value of the menu item, an instance of the DropdownPage enumeration
          value: DropdownPage.settings,
          // Text widget that displays the text for the menu item
          child: Text(AppLocalizations.of(context)!.settings,
              style: TextStyle(color: swatch[801])),
        ),
        // Third menu item
        PopupMenuItem<DropdownPage>(
          // Value of the menu item, an instance of the DropdownPage enumeration
          value: DropdownPage.saved,
          // Text widget that displays the text for the menu item
          child: Text(AppLocalizations.of(context)!.saved,
              style: TextStyle(color: swatch[801])),
        ),
      ],
    );
  }
}

// Creates a grid tile widget from an image URL
Widget _createGridTileWidget(Map<String, dynamic> post,
    dynamic imageViewerController, Function refreshPage) {
  return Builder(builder: (context) {
    void popNavigator() {
      Navigator.of(context).pop();
    }

    return GestureDetector(
      onLongPress: () async {
        await showDialog(
          useRootNavigator: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                backgroundColor: swatch[800],
                title: Text(
                  'Are you sure you want to delete this post?',
                  style: TextStyle(color: swatch[701]),
                ),
                content: SizedBox(
                    height: 96,
                    child: Column(children: [
                      TextButton(
                        onPressed: () async {
                          await SocialAPI.delPost(post["post_id"]);
                          refreshPage();
                          popNavigator();
                        },
                        child: Text(
                          'Delete',
                          style: TextStyle(color: swatch[901]),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          popNavigator();
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: swatch[901]),
                        ),
                      )
                    ])));
          },
        );
      },
      //onLongPressEnd: (details) => _popupDialog?.remove(),
      onTap: () => {currentImage = post["image"], imageViewerController()},
      child: CachedNetworkImage(
        imageUrl: '${Config.uri}/image/thumbnail/${post["image"]}',
        fit: BoxFit.cover,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
                8), // Set the shape of the container to a circle
            image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
          ),
        ),
      ), // Display the image from the URL
    );
  });
}

class UserPostsList extends StatefulWidget {
  final Map<String, dynamic>? user;

  final dynamic imageViewerController;
  const UserPostsList(
      {super.key, required this.user, required this.imageViewerController});

  @override
  State<UserPostsList> createState() => _UserPostsListState();
}

class _UserPostsListState extends State<UserPostsList> {
  // Define the page size used for pagination
  static const _pageSize = 20;

  // Create a PagingController to manage pagination
  final PagingController<int, Map<String, dynamic>> _pagingController =
      PagingController(firstPageKey: 0);

  Widget _createGridLoadingWidgets() {
    Widget child = Shimmer.fromColors(
        baseColor: shimmer["base"]!,
        highlightColor: shimmer["highlight"]!,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset("assets/placeholders/150.png"),
        ));
    return GridView(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        // Specify the properties for the grid tiles
        childAspectRatio: 1,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        maxCrossAxisExtent: MediaQuery.of(context).size.width / 3,
      ),
      children: [
        child,
        child,
        child,
        child,
        child,
        child,
        child,
        child,
        child,
        child,
        child,
        child
      ],
    );
  }

  @override
  void initState() {
    // Add a listener to the PagingController that fetches the next page when requested
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  void refreshPage() {
    _pagingController.refresh();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      // Fetch the next page of posts from the user's account
      final page =
          await SocialAPI.getUserPosts(widget.user?["user_id"], pageKey);

      // Determine if this is the last page of posts
      final isLastPage = page.length < _pageSize;

      if (isLastPage && mounted) {
        // If this is the last page of posts, append it to the PagingController as the final page
        if ((_pagingController.itemList == null ||
                _pagingController.itemList!.isEmpty) &&
            page.isEmpty) {
          _pagingController.appendLastPage(page);
        } else {
          int rem =
              4 - ((_pagingController.itemList?.length ?? 0) + page.length) % 3;
          List<Map<String, dynamic>> spacers = [];
          for (int i = 0; i < rem; i++) {
            spacers.add({"last": true});
          }
          _pagingController.appendLastPage([...page, ...spacers]);
        }
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
              firstPageProgressIndicatorBuilder: (context) =>
                  _createGridLoadingWidgets(),
              noItemsFoundIndicatorBuilder: (context) => ListError(
                  title: AppLocalizations.of(context)!.noPostsFound, body: ""),
              // Specify how to build each grid tile
              itemBuilder: (context, item, index) => item["last"] == true
                  ? const SizedBox(
                      height: 72,
                    )
                  : _createGridTileWidget(
                      item, widget.imageViewerController, refreshPage),
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
      commonLogger.e("An error has occured: $e");
    }
    super.dispose();
  }
}

class ConnectionLists extends StatelessWidget {
  final Map<String, dynamic>? user;

  const ConnectionLists({super.key, this.user});
  @override
  Widget build(BuildContext context) {
    String? self = "";
    if (user != null) {
      MessagesAPI.getUserId().then((value) => self = value);
    }
    return Expanded(
        child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: const Color.fromARGB(125, 0, 0, 0),
                borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Spacer(),
              GestureDetector(
                  onTap: () => Navigator.push(
                      // Send to edit profile page
                      context,
                      MaterialPageRoute(
                          builder: (context) => FriendsList(
                                user: user?["user_id"] != self ? user : null,
                              ))),
                  child: Column(children: [
                    Text((user?["friends"] ?? 0).toString(),
                        style: TextStyle(color: swatch[601])),
                    Text(AppLocalizations.of(context)!.friends,
                        style: TextStyle(color: swatch[701]))
                  ])),
              // Column to display the number of followers
              const Spacer(),

              GestureDetector(
                  onTap: () => Navigator.push(
                      // Send to edit profile page
                      context,
                      MaterialPageRoute(
                          builder: (context) => Lists(
                                index: 0,
                                user: user?["user_id"] != self ? user : null,
                              ))),
                  child: Column(children: [
                    Text((user?["followers"] ?? 0).toString(),
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
                          builder: (context) => Lists(
                                index: 1,
                                user: user?["user_id"] != self ? user : null,
                              ))),
                  child: Column(children: [
                    Text((user?["following"] ?? 0).toString(),
                        style: TextStyle(color: swatch[601])),
                    Text(AppLocalizations.of(context)!.following,
                        style: TextStyle(color: swatch[701]))
                  ])),
              const Spacer(),
            ])));
  }
}
