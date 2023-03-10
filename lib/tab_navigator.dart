import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:skating_app/new_post/new_post.dart';
import 'package:skating_app/profile/profile_page.dart';
import 'package:skating_app/test2.dart';
import 'friends_tracker/friends_tracker.dart';
import 'social_media/homepage.dart';
import 'fitness_tracker/fitness_tracker.dart';

class TabNavigator extends StatelessWidget {
  const TabNavigator(
      {super.key,
      required this.navigatorKey,
      required this.tabItemIndex, // Navbar item selected
      required this.tabitems}); // Array of navbar items
  final GlobalKey<NavigatorState>? navigatorKey;
  final int tabItemIndex;
  final List<TabItem<Widget>> tabitems;

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    return {
      // When called will output a route according to the index button pressed
      "0": (context) => HomePage(
            title: 'Home', // Assign Homepage to index 0 and so on
          ),
      "1": (context) => const FitnessTracker(
            title: "Fitness Tracker", // Link to fitness tracker
          ),
      "2": (context) =>
          const NewPost(title: "New Post"), // Link to new post page
      "3": (context) => const FriendsTracker(
          title: "Friends Tracker"), // Link To friends tracker,
      "4": (context) => const ProfilePage(
            title: 'Profile Page',
          ), //  Link to Profile Page
    };
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders(context);
/*
    int index = 0;
    for (var i = 0; i < tabitems.length; i++) {
      print("loop1 $i");
      if (tabitems[i].icon. == tabItem.icon) {
        print("loop2 $i");
        index = i;
        break;
      }
      //statements
    }*/
    //String i = tabitems
    //    .indexOf(tabItem) //Get the index of the tab selected
    //    .toString(); //Convert to string

    return Navigator(
        key: navigatorKey,
        initialRoute: "0", //Set initial page to main page
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
              builder: (context) => routeBuilders[tabItemIndex.toString()]!(
                  context)); //Get page at index i
        });
  }
}
