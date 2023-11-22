import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:patinka/api/image.dart';
import 'package:patinka/caching/manager.dart';
import 'package:patinka/login/login.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/api/websocket.dart';
import 'package:patinka/api/token.dart';
import 'package:verify/verify.dart';
import 'api/config.dart';
import 'api/social.dart';
import 'common_logger.dart';
import 'misc/default_profile.dart';
import 'swatch.dart';
import 'tab_navigator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'current_tab.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import './misc/navbar_provider.dart';
import './friends_tracker/caching/map_cache.dart'
    if (dart.library.io) './friends_tracker/caching/map_cache_mobile.dart'
    if (dart.library.html) './friends_tracker/caching/map_cache_web.dart';
import './window_manager/window_manager.dart';
import 'package:patinka/firebase/init_firebase.dart';
import 'package:path/path.dart' as path;
// AndroidNotificationChannel channel = const AndroidNotificationChannel(
//   'ChannelId', // id
//   'ChannelId', // title
//   description:
//       'This channel is used for important notifications.', // description
//   importance: Importance.high,
// );

// Define the main function
Future<void> main() async {
  // Ensure that the Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  await initialiseFirebase();

  await initialiseWindowManager();
  //FirebaseMessaging.instance.deleteToken();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:
          Colors.transparent, //swatch[200], // transparent status bar
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Initialize the FlutterMapTileCaching package for caching map tiles
  await initialiseCache();
  // Register a singleton instance of WebSocketConnection class with GetIt dependency injection
  GetIt.I.registerSingleton<WebSocketConnection>(WebSocketConnection());

  // Run the app with the MyApp widget
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<BottomBarVisibilityProvider>(
      create: (_) => BottomBarVisibilityProvider(),
    ),
  ], child: Phoenix(child: const MyApp())));
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
              mounted ? setState(() => loggedIn = true) : null,
            }
        });

// Function to set the logged in state of the user
    void setLoggedIn(value) {
      // Update state to reflect whether the user is logged in or not
      mounted ? setState(() => loggedIn = value) : null;
    }

    return MaterialApp(
      title: 'Patinka',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: ThemeMode.dark,
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
        primarySwatch: const MaterialColor(0xff1eb723, swatch),
        fontFamily: "OpenSans",
        colorScheme: ColorScheme.fromSwatch(
            primarySwatch: const MaterialColor(0xff1eb723, swatch),
            brightness: Brightness.dark),
      ),
      home: loggedIn
          ? StateManagement(setLoggedIn: setLoggedIn, loggedIn: loggedIn)
          : LoginPage(
              setLoggedIn: setLoggedIn,
              loggedIn:
                  loggedIn), //Login(setLoggedIn: setLoggedIn, loggedIn: loggedIn),
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
    super.key,
    required this.loggedIn,
    required this.setLoggedIn,
  });

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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  //Image backgroundImage = Image.file()
  ImageProvider backgroundImage =
      const AssetImage("assets/backgrounds/graffiti_low_res.png");
  int selectedpage = 0;
  String? avatar;
  @override
  void initState() {
    void getImage(String filePath) {
      getApplicationDocumentsDirectory().then((applicationDocumentsDirectory) {
        File file = File(path
            .join(applicationDocumentsDirectory.path, path.basename(filePath))
            .replaceAll('"',
                '')); // Replace all " because it breaks it for some weird reason
        commonLogger.d(file.existsSync());
        FileImage fileImage = FileImage(file);
        setState(() => backgroundImage = fileImage);
      });
    }

    storage.getId().then((value) => {
          value != null
              ? SocialAPI.getUser(value).then((user) => {
                    mounted
                        ? setState(() {
                            avatar = user["avatar_id"];
                          })
                        : null
                  })
              : setState(() {
                  avatar = "default";
                })
        });
    NetworkManager.instance
        .getLocalData(name: "current-background", type: CacheTypes.background)
        .then((filePath) {
      if (filePath != null) {
        getImage(filePath);
      } else {
        MediaQueryData mediaQuery = MediaQuery.of(context);
        final physicalPixelWidth =
            mediaQuery.size.width * mediaQuery.devicePixelRatio;
        final physicalPixelHeight =
            mediaQuery.size.height * mediaQuery.devicePixelRatio;
        downloadBackgroundImage(physicalPixelWidth, physicalPixelHeight)
            .then((value) {
          if (value) {
            commonLogger.d("Downloading Value is true");
            NetworkManager.instance
                .getLocalData(
                    name: "current-background", type: CacheTypes.background)
                .then((filePath) {
              if (filePath != null) {
                commonLogger.d("File path aint none");
                getImage(filePath);
              }
            });
          }
        });
      }
    });
    super.initState();
  }

  List<TabItem<Widget>> tabItems() {
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
        icon: avatar == null
            // If there is no cached user information or avatar image, use a default image
            ? Shimmer.fromColors(
                baseColor: shimmer["base"]!,
                highlightColor: shimmer["highlight"]!,
                child: CircleAvatar(
                  // Create a circular avatar icon
                  radius: 36, // Set radius to 36
                  backgroundColor: swatch[900],
                ))
            // If there is cached user information and an avatar image, use the cached image
            : avatar != "default"
                ? CachedNetworkImage(
                    imageUrl: '${Config.uri}/image/thumbnail/$avatar',
                    placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: shimmer["base"]!,
                        highlightColor: shimmer["highlight"]!,
                        child: CircleAvatar(
                          // Create a circular avatar icon
                          radius: 36, // Set radius to 36
                          backgroundColor: swatch[900],
                        )),
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape
                            .circle, // Set the shape of the container to a circle
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.contain),
                      ),
                    ),
                  )
                : const DefaultProfile(radius: 36),
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

  Future<bool> handlePop(CurrentPage currentPage) async {
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
    commonLogger.d(backgroundImage.toString());
    return Consumer<CurrentPage>(builder: (context, currentPage, child) {
      return WillPopScope(
          // Handle user swiping back inside application
          onWillPop: () => handlePop(currentPage),
          child: Scaffold(
              extendBody: true,
              bottomNavigationBar: Consumer<BottomBarVisibilityProvider>(
                builder: (context, bottomBarVisibilityProvider, child) {
                  return AnimatedBuilder(
                    animation: bottomBarVisibilityProvider.animationController,
                    builder: (context, child) {
                      final translateY = Tween<double>(
                        begin:
                            bottomBarVisibilityProvider.isVisible ? 0.0 : 1.0,
                        end: bottomBarVisibilityProvider.isVisible ? 1.0 : 0.0,
                      )
                          .animate(
                              bottomBarVisibilityProvider.animationController)
                          .value;

                      return Transform.translate(
                        offset: Offset(0.0,
                            translateY * 85.0), // Adjust the height as needed
                        child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: !bottomBarVisibilityProvider.isVisible
                                ? const Wrap() // Hide the widget when visible
                                : Wrap(
                                    children: [
                                      StyleProvider(
                                        style: Style(),
                                        child: ConvexAppBar(
                                          //Define Navbar Object
                                          items:
                                              tabItems(), //Set navbar items to the tabitems
                                          initialActiveIndex: currentPage
                                              .tab, // Set initial selection to main page
                                          onTap: (int i) => {
                                            //When a navbar button is pressed set the current tab to the tabitem that was pressed
                                            mounted
                                                ? setState(() {
                                                    //  _currentTab = i;
                                                    currentPage.set(i);
                                                  })
                                                : null,
                                            commonLogger.t(
                                                "Setting the current page: $i")
                                          }, // When a button is pressed... output to console
                                          style: TabStyle
                                              .fixedCircle, // Set the navbar style to have the circle stay at the centre
                                          backgroundColor: const Color.fromARGB(
                                              184, 32, 49, 33), //swatch[51],
                                          activeColor: const Color.fromARGB(
                                              51,
                                              31,
                                              175,
                                              31), //const Color(0x667fea82),
                                          shadowColor: Colors.green,
                                          color: const Color.fromARGB(
                                              51, 0, 23, 0),
                                          //backgroundColor: const AssetImage("assets/backgrounds/navbar_background.png"),
                                          height: 55,
                                        ),
                                      ),
                                    ],
                                  )),
                      );
                    },
                  );
                },
              ),
              body: Stack(
                children: [
                  SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: const ClampingScrollPhysics(
                          parent: NeverScrollableScrollPhysics()),
                      child: Container(
                          constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.height,
                              minWidth: MediaQuery.of(context).size.width),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: backgroundImage,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.4),
                                    BlendMode.srcOver)),
                          ),
                          padding: const EdgeInsets.all(16))),
                  // Create a navigator stack for each item
                  _buildOffstageNavigator(currentPage, 0),
                  _buildOffstageNavigator(currentPage, 1),
                  _buildOffstageNavigator(currentPage, 2),
                  _buildOffstageNavigator(currentPage, 3),
                  _buildOffstageNavigator(currentPage, 4),
                ],
              )

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
