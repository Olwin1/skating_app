import "package:convex_bottom_bar/convex_bottom_bar.dart";
import "package:flutter/material.dart";
import "package:patinka/fitness_tracker/fitness_tracker.dart";
import "package:patinka/friends_tracker/friends_tracker.dart";
import "package:patinka/new_post/new_post.dart";
import "package:patinka/profile/profile_page/profile_page.dart";
import "package:patinka/services/navigation_service.dart";
import "package:patinka/social_media/homepage.dart";

class TabNavigator extends StatelessWidget {
  const TabNavigator(
      {required this.tabItemIndex,
      required this.tabitems,
      super.key}); // Navbar item selected // Array of navbar items, super.key,
  final int tabItemIndex;
  final List<TabItem<Widget>> tabitems;

  static const Map<String, Widget> _routeBuilders = {
    // When called will output a route according to the index button pressed
    "0": HomePage(), // Assign Homepage to index 0 and so on
    "1": FitnessTracker(),
    "2": NewPost(), // Link to new post page
    "3": FriendsTracker(), // Link To friends tracker,
    "4": ProfilePage(
      userId: "0",
      navbar: true,
    ), //  Link to Profile Page
  };

  @override
  Widget build(final BuildContext context) => Navigator(
      key: NavigationService.navigatorKey(tabItemIndex.toString()),
      initialRoute: "0", //Set initial page to main page
// TODO: opPopPage deprecated after Flutter 3.24 - change handler at that point for back on last route.
      onDidRemovePage: (final Page<Object?> page) {
        // if (!route.didPop(result)) {
        //   return false;
        // }

        // if (NavigationService.getCurrentIndex() != 0) {
        //   print("cows");
        // PushReplacement to index 0
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   NavigationService.navigatorKey("0")
        //       ?.currentState
        //       ?.pushReplacementNamed("/");
        // });
        // NavigationService.setCurrentIndex(0);

        // return route.didPop(result);
      },
      onGenerateRoute: (final routeSettings) => MaterialPageRoute(
          builder: (final context) =>
              _routeBuilders[tabItemIndex.toString()]!)); //Get page at index i
}
