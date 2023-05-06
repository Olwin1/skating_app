import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:skating_app/api/websocket.dart';
import 'package:skating_app/api/token.dart';
import 'package:skating_app/social_media/login.dart';
import 'tab_navigator.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'current_tab.dart';
import 'package:provider/provider.dart';

// Define the main function
Future<void> main() async {
  // Ensure that the Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the FlutterMapTileCaching package for caching map tiles
  await FlutterMapTileCaching.initialise();

  // Create an instance of the cache manager for map tiles and register it with GetIt dependency injection
  FMTC.instance('mapCache').manage.create();

  // Register a singleton instance of WebSocketConnection class with GetIt dependency injection
  GetIt.I.registerSingleton<WebSocketConnection>(WebSocketConnection());

  // Run the app with the MyApp widget
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

SecureStorage storage = SecureStorage();

class _MyAppState extends State<MyApp> {
  int selectedpage = 0;
  bool loggedIn = false;
  @override
  Widget build(BuildContext context) {
    // Retrieve token from storage
    storage.getToken().then((token) => {
          // Check if token exists and user is not already logged in
          if (token != null && !loggedIn)
            {
              // Update state to indicate user is now logged in
              setState(() => loggedIn = true),
            }
        });

// Function to set the logged in state of the user
    setLoggedIn(value) {
      // Update state to reflect whether the user is logged in or not
      setState(() => {loggedIn = value});
    }

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
        fontFamily: "OpenSans",
      ),
      home: loggedIn
          ? StateManagement(setLoggedIn: setLoggedIn, loggedIn: loggedIn)
          : Login(setLoggedIn: setLoggedIn, loggedIn: loggedIn),
    );
  }
}

// This is a stateless widget called StateManagement
class StateManagement extends StatelessWidget {
  // This widget requires two parameters, a boolean named `loggedIn`
  // and a dynamic named `setLoggedIn`
  final bool loggedIn;
  final dynamic setLoggedIn;

  // Constructor for this widget that initializes its properties
  const StateManagement({
    Key? key,
    required this.loggedIn,
    required this.setLoggedIn,
  }) : super(key: key);

  // Build method of this widget that returns a ChangeNotifierProvider widget
  // with a CurrentPage object as the notifier and a child MyHomePage widget.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CurrentPage>(
      create: (_) => CurrentPage(),
      child: MyHomePage(
        loggedIn: loggedIn,
        setLoggedIn: setLoggedIn,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.loggedIn, this.setLoggedIn});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final bool loggedIn;
  final dynamic setLoggedIn;

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
        icon: Image.asset("assets/icons/navbar/new_post.png"),
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

  final Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    "0": GlobalKey<
        NavigatorState>(), //Create an individual navigation stack for each item
    "1": GlobalKey<NavigatorState>(),
    "2": GlobalKey<NavigatorState>(),
    "3": GlobalKey<NavigatorState>(),
    "4": GlobalKey<NavigatorState>(),
  };
  void _selectTab(
      CurrentPage currentPage, TabItem<Widget> tabItem, String index) {
    if (index == currentPage.tab.toString()) {
      // If current tab is main tab
      // pop to first route
      _navigatorKeys[index]!.currentState!.popUntil((route) =>
          route.isFirst); //Reduce navigation stack until back to that page
    } else {
      //setState(
      currentPage.set(int.parse(index)); //); // Set current tab to main page
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
// This code returns a Consumer widget that rebuilds its child widget
// whenever the CurrentPage object changes.
    return Consumer<CurrentPage>(builder: (context, currentPage, child) {
    return WillPopScope(
        // Handle user swiping back inside application
        onWillPop: () async {
          final isFirstRouteInCurrentTab =
                !await _navigatorKeys[currentPage.tab.toString()]!
                  .currentState!
                  .maybePop();
          if (isFirstRouteInCurrentTab) {
            // if not on the 'main' tab
              if (currentPage.tab != 0) {
              // select 'main' tab
                _selectTab(currentPage, tabItems()[0], "0");
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
                initialActiveIndex:
                    currentPage.tab, // Set initial selection to main page
              onTap: (int i) => {
                //When a navbar button is pressed set the current tab to the tabitem that was pressed
                setState(() {
                    //  _currentTab = i;
                    currentPage.set(i);
                }),
                  print("setting curret page")
              }, // When a button is pressed... output to console
              style: TabStyle
                  .fixedCircle, // Set the navbar style to have the circle stay at the centre
              backgroundColor: const Color(0xffcfcfcf),
              activeColor: const Color(0xffbebebe),
              //backgroundColor: const AssetImage("assets/backgrounds/navbar_background.png"),
              height: 55,
            ),
          ),
          body: Stack(
            children: [
              // Create a navigator stack for each item
                _buildOffstageNavigator(currentPage, 0),
                _buildOffstageNavigator(currentPage, 1),
                _buildOffstageNavigator(currentPage, 2),
                _buildOffstageNavigator(currentPage, 3),
                _buildOffstageNavigator(currentPage, 4)
            ],
          ),
          // This trailing comma makes auto-formatting nicer for build methods.
        ));
    }); //);
  }

  Widget _buildOffstageNavigator(CurrentPage currentPage, int tabItemIndex) {
    if (currentPage.tab == tabItemIndex) {}
    return Offstage(
      offstage: currentPage.tab != tabItemIndex,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[tabItemIndex.toString()],
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
