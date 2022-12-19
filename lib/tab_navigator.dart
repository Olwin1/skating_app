import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:skating_app/test2.dart';
import 'social_media/homepage.dart';

class TabNavigator extends StatelessWidget {
  const TabNavigator(
      {super.key,
      required this.navigatorKey,
      required this.tabItem, // Navbar item selected
      required this.tabitems}); // Array of navbar items
  final GlobalKey<NavigatorState>? navigatorKey;
  final TabItem tabItem;
  final List<TabItem> tabitems;

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    return {
      // When called will output a route according to the index button pressed
      "0": (context) => const HomePage(
            title: 'Home', // Assign Homepage to index 0 and so on
          ),
      "1": (context) => const Testingt(),
      "2": (context) => const Testingt(),
      "3": (context) => const Testingt(),
      "4": (context) => const Testingt(),
    };
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders(context);
    String i = tabitems
        .indexOf(tabItem) //Get the index of the tab selected
        .toString(); //Convert to string

    return Navigator(
        key: navigatorKey,
        initialRoute: "0", //Set initial page to main page
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
              builder: (context) =>
                  routeBuilders[i]!(context)); //Get page at index i
        });
  }
}
