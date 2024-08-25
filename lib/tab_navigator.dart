import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:patinka/new_post/new_post.dart';
import 'package:patinka/profile/profile_page/profile_page.dart';
import 'friends_tracker/friends_tracker.dart';
import 'services/navigation_service.dart';
import 'social_media/homepage.dart';
import 'fitness_tracker/fitness_tracker.dart';

class TabNavigator extends StatelessWidget {
  const TabNavigator(
      {super.key,
      required this.tabItemIndex, // Navbar item selected
      required this.tabitems}); // Array of navbar items
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
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders;

    return Navigator(
        key: NavigationService.navigatorKey(tabItemIndex.toString()),
        initialRoute: "0", //Set initial page to main page
// TODO: opPopPage deprecated after Flutter 3.24 - change handler at that point for back on last route.
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          if (NavigationService.getCurrentIndex() != 0) {
            print("cows");
            // PushReplacement to index 0
            // WidgetsBinding.instance.addPostFrameCallback((_) {
            //   NavigationService.navigatorKey("0")
            //       ?.currentState
            //       ?.pushReplacementNamed("/");
            // });
            // NavigationService.setCurrentIndex(0);
          }
          print("cos");

          return route.didPop(result);
        },
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(builder: (context) {
            return routeBuilders[tabItemIndex.toString()]!;
          }); //Get page at index i
        });
  }
}
