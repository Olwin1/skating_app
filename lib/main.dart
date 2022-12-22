import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
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

  static List<TabItem<Widget>> tabItems() {
    return ([
      TabItem<Widget>(
        //icon: Icons.home,
        icon: Image.asset(
          "assets/icons/navbar/home.png",
          height: 100,
        ),
      ), // Create Homepage Button Object
      TabItem<Widget>(
        //icon: Icons.home,
        icon: Image.asset("assets/icons/navbar/fitness_tracker.png"),
      ), // Create Fitness Tracker Button Object
      TabItem<Widget>(
        //icon: Icons.home,
        icon: Image.asset("assets/icons/navbar/home_2.png"),
      ), // Create Create New Post Button Object
      TabItem<Widget>(
        //icon: Icons.home,
        icon: Image.asset("assets/icons/navbar/friend_tracker.png"),
      ), // Create friends tracker Button Object
      TabItem<Widget>(
        //icon: Icons.home,
        icon: Image.asset("assets/placeholders/150.png"),
      ), // Create Profile Button Object
    ]);
  }

  int _currentTab = 0; // Declare _current tab and set default to main page
  final Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    "0": GlobalKey<
        NavigatorState>(), //Create an individual navigation stack for each item
    "1": GlobalKey<NavigatorState>(),
    "2": GlobalKey<NavigatorState>(),
    "3": GlobalKey<NavigatorState>(),
    "4": GlobalKey<NavigatorState>(),
  };
  void _selectTab(TabItem<Widget> tabItem, String index) {
    if (index == _currentTab.toString()) {
      // If current tab is main tab
      // pop to first route
      _navigatorKeys[index]!.currentState!.popUntil((route) =>
          route.isFirst); //Reduce navigation stack until back to that page
    } else {
      setState(
          () => _currentTab = int.parse(index)); // Set current tab to main page
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
              !await _navigatorKeys[_currentTab.toString()]!
                  .currentState!
                  .maybePop();
          if (isFirstRouteInCurrentTab) {
            // if not on the 'main' tab
            if (_currentTab != 0) {
              // select 'main' tab
              _selectTab(tabItems()[0], "0");
              // back button handled by app
              return false;
            }
          }
          // let system handle back button if on the first route
          return isFirstRouteInCurrentTab;
        },
        child: Scaffold(
          bottomNavigationBar: StyleProvider(
            style: Style(),
            child: ConvexAppBar(
              //Define Navbar Object
              items: tabItems(), //Set navbar items to the tabitems
              initialActiveIndex: 0, // Set initial selection to main page
              onTap: (int i) => {
                //When a navbar button is pressed set the current tab to the tabitem that was pressed
                setState(() {
                  _currentTab = i;
                }),
              }, // When a button is pressed... output to console
              style: TabStyle
                  .fixedCircle, // Set the navbar style to have the circle stay at the centre
              backgroundColor: const Color.fromARGB(255, 153, 135, 0),
              height: 55,
            ),
          ),
          body: Stack(
            children: [
              // Create a navigator stack for each item
              _buildOffstageNavigator(0),
              _buildOffstageNavigator(1),
              _buildOffstageNavigator(2),
              _buildOffstageNavigator(3),
              _buildOffstageNavigator(4)
            ],
          ),
          // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }

  Widget _buildOffstageNavigator(int tabItemIndex) {
    return Offstage(
      offstage: _currentTab != tabItemIndex,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[tabItemIndex],
        tabItemIndex: tabItemIndex,
        tabitems: tabItems(),
      ),
    );
  }
}

class Style extends StyleHook {
  @override
  double get iconSize => 50;

  @override
  double get activeIconMargin => 10;
  @override
  double get activeIconSize => 60;

  @override
  TextStyle textStyle(Color color, String? fontFamily) {
    return TextStyle(fontSize: 20, color: color);
  }
}
