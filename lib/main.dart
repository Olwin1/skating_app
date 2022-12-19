import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:skating_app/test2.dart';
import 'tab_navigator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedpage = 0;

  static tabItems() {
    return ([
      const TabItem(
        icon: Icons.home,
      ), // Create Homepage Button Object
      const TabItem(
          icon: Icons.roller_skating), // Create Fitness Tracker Button Object
      const TabItem(icon: Icons.add), // Create Create New Post Button Object
      const TabItem(icon: Icons.map), // Create friends tracker Button Object
      const TabItem(icon: Icons.person), // Create Profile Button Object
    ]);
  }

  TabItem _currentTab =
      tabItems()[0]; // Declare _current tab and set default to main page
  final Map<TabItem, GlobalKey<NavigatorState>> _navigatorKeys = {
    tabItems()[0]: GlobalKey<
        NavigatorState>(), //Create an individual navigation stack for each item
    tabItems()[1]: GlobalKey<NavigatorState>(),
    tabItems()[2]: GlobalKey<NavigatorState>(),
    tabItems()[3]: GlobalKey<NavigatorState>(),
    tabItems()[4]: GlobalKey<NavigatorState>(),
  };
  void _selectTab(TabItem tabItem) {
    if (tabItem == _currentTab) {
      // If current tab is main tab
      // pop to first route
      _navigatorKeys[tabItem]!.currentState!.popUntil((route) =>
          route.isFirst); //Reduce navigation stack until back to that page
    } else {
      setState(() => _currentTab = tabItem); // Set current tab to main page
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return WillPopScope(
        // Handle user swiping back inside application
        onWillPop: () async {
          final isFirstRouteInCurrentTab =
              !await _navigatorKeys[_currentTab]!.currentState!.maybePop();
          if (isFirstRouteInCurrentTab) {
            // if not on the 'main' tab
            if (_currentTab != tabItems()[0]) {
              // select 'main' tab
              _selectTab(tabItems()[0]);
              // back button handled by app
              return false;
            }
          }
          // let system handle back button if on the first route
          return isFirstRouteInCurrentTab;
        },
        child: Scaffold(
          bottomNavigationBar: ConvexAppBar(
            //Define Navbar Object
            items: tabItems(), //Set navbar items to the tabitems
            initialActiveIndex: 0, // Set initial selection to main page
            onTap: (int i) => {
              //When a navbar button is pressed set the current tab to the tabitem that was pressed
              setState(() {
                _currentTab = tabItems()[i];
              }),
            }, // When a button is pressed... output to console
            style: TabStyle
                .fixedCircle, // Set the navbar style to have the circle stay at the centre
          ),
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(widget.title),
          ),
          body: Stack(
            children: [
              // Create a navigator stack for each item
              _buildOffstageNavigator(tabItems()[0]),
              _buildOffstageNavigator(tabItems()[1]),
              _buildOffstageNavigator(tabItems()[2]),
              _buildOffstageNavigator(tabItems()[3]),
              _buildOffstageNavigator(tabItems()[4])
            ],
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }

  Widget _buildOffstageNavigator(TabItem tabItem) {
    return Offstage(
      offstage: _currentTab != tabItem,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[tabItem],
        tabItem: tabItem,
        tabitems: tabItems(),
      ),
    );
  }
}
