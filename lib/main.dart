import "dart:async";

import "package:cached_network_image/cached_network_image.dart";
import "package:convex_bottom_bar/convex_bottom_bar.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_phoenix/flutter_phoenix.dart";
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import "package:get_it/get_it.dart";
import "package:in_app_notification/in_app_notification.dart";
import "package:patinka/api/auth.dart";
import "package:patinka/api/config/config.dart";
import "package:patinka/api/social.dart";
import "package:patinka/api/token.dart";
import "package:patinka/api/websocket.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/firebase/init_firebase.dart";
import "package:patinka/l10n/app_localizations.dart";
// import "package:patinka/friends_tracker/caching/map_cache.dart"
//     if (dart.library.io) "./friends_tracker/caching/map_cache_mobile.dart"
//     if (dart.library.html) "./friends_tracker/caching/map_cache_web.dart";
import "package:patinka/login/login.dart";
import "package:patinka/misc/default_profile.dart";
import "package:patinka/misc/navbar_provider.dart";
import "package:patinka/services/navigation_service.dart";
import "package:patinka/social_media/utils/utils/utils.dart";
import "package:patinka/swatch.dart";
import "package:patinka/tab_navigator.dart";
import "package:patinka/window_manager/window_manager_stub.dart"
    if (dart.library.io) "package:patinka/window_manager/window_manager_desktop.dart";
import "package:provider/provider.dart";
import "package:shimmer/shimmer.dart";

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
  //await initialiseCache();
  // Register a singleton instance of WebSocketConnection class with GetIt dependency injection
  GetIt.I.registerSingleton<WebSocketConnection>(WebSocketConnection());

  // Run the app with the MyApp widget
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<BottomBarVisibilityProvider>(
      create: (final _) => BottomBarVisibilityProvider(),
    ),
  ], child: Phoenix(child: const InAppNotification(child: MyApp()))));
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
  Widget build(final BuildContext context) {
    // Retrieve token from storage
    storage.getToken().then((final token) => {
          // Check if token exists and user is not already logged in
          if (token != null && !loggedIn)
            {
              // Update state to indicate user is now logged in
              mounted ? setState(() => loggedIn = true) : null,
            }
        });

// Function to set the logged in state of the user
    void setLoggedIn(final value) {
      // Update state to reflect whether the user is logged in or not
      mounted ? setState(() => loggedIn = value) : null;
    }

    return MaterialApp(
      title: "Patinka",
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
          ? PunishmentEnforcer(setLoggedIn: setLoggedIn, loggedIn: loggedIn)
          : LoginPage(setLoggedIn: setLoggedIn, loggedIn: loggedIn),
    );
  }
}

class PunishmentEnforcer extends StatefulWidget {
  const PunishmentEnforcer(
      {required this.setLoggedIn, required this.loggedIn, super.key});

  final dynamic setLoggedIn;
  final bool loggedIn;

  @override
  State<PunishmentEnforcer> createState() => _PunishmentEnforcer();
}

class _PunishmentEnforcer extends State<PunishmentEnforcer> {
  Map<String, dynamic>? punishmentData;
  ImageProvider backgroundImage =
      const AssetImage("assets/backgrounds/graffiti_low_res.png");

  @override
  void initState() {
    AuthenticationAPI.isRestricted().then((final response) => setState(() {
          punishmentData = response;
          storage.setMuted(response["is_muted"], response["end_timestamp"]);
        }));

    super.initState();
  }

  //const result = await AuthenticationAPI.isPunished();
  @override
  Widget build(final BuildContext context) {
    if (punishmentData == null) {
      // TODO implement custom splash screen
      return const SizedBox(child: Text("loading"));
    }
    commonLogger.i("Running the punishment enforcer");
    if (punishmentData!["is_banned"]) {
      // Display a special screen if the user is banned that cannot be exitied out of.
      return Scaffold(
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
                            Colors.black.withValues(alpha: 0.4),
                            BlendMode.srcOver)),
                  ),
                  padding: const EdgeInsets.all(16))),
          Center(
              child: Container(
                  color: Colors.blueGrey.shade900,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Looks like you've been taken off the rink!",
                          style: TextStyle(
                              fontSize: 28, color: Colors.red.shade500),
                          textAlign: TextAlign.center,
                        ),
                        RichText(
                          text: const TextSpan(
                            text: "You have been banned for ",
                            style: TextStyle(),
                            children: <TextSpan>[
                              TextSpan(
                                  text: "6 days",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text:
                                      " once this time has elapsed then you will be able to access the app as normal."),
                            ],
                          ),
                        )
                      ]))),
          Positioned(
              top: 55,
              right: 20,
              child: DecoratedBox(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Colors.grey.shade900),
                  child: IconButton(
                    onPressed: () => {
                      // Remove stored tokens and restart app
                      storage.logout().then((final value) => {
                            if (context.mounted) {Phoenix.rebirth(context)}
                          })
                    },
                    icon: const Icon(Icons.logout),
                    color: Colors.red.shade700,
                  )))
        ],
      ));
    } else {
      return StateManagement(
          setLoggedIn: widget.setLoggedIn, loggedIn: widget.loggedIn);
    }
  }
}

// This is a stateless widget called StateManagement
class StateManagement extends StatelessWidget {
  // Constructor for this widget that initializes its properties
  const StateManagement({
    required this.loggedIn,
    required this.setLoggedIn,
    super.key,
  });
  // This widget requires two parameters, a boolean named `loggedIn`
  // and a dynamic named `setLoggedIn`
  final bool loggedIn;
  final dynamic setLoggedIn;

  // Build method of this widget that returns a ChangeNotifierProvider widget
  // with a CurrentPage object as the notifier and a child MyHomePage widget.
  @override
  Widget build(final BuildContext context) =>
      ChangeNotifierProvider<NavigationService>(
        create: (final _) => NavigationService.instance,
        child: MyHomePage(
          loggedIn: loggedIn,
          setLoggedIn: setLoggedIn,
        ),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.loggedIn, super.key, this.setLoggedIn});

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
  bool gottenAvatar = false;

  @override
  void initState() {
    storage.getId().then((final value) => {
          value != null
              ? {
                  SocialAPI.getUser(value).then((final user) => {
                        mounted
                            ? setState(() {
                                avatar = user["avatar_id"];
                              })
                            : null
                      }),
                  gottenAvatar = true
                }
              : setState(() {
                  avatar = null;
                })
        });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // Download the image if its not already downloaded
    void getImage(final String filePath) {
      Utils.getImage(filePath,
          (final fileImage) => setState(() => backgroundImage = fileImage));
    }

    super.didChangeDependencies();
    Utils.loadImage(getImage, MediaQuery.of(context));
  }

  List<TabItem<Widget>> tabItems() => [
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
                      imageUrl: "${Config.uri}/image/thumbnail/$avatar",
                      placeholder: (final context, final url) =>
                          Shimmer.fromColors(
                              baseColor: shimmer["base"]!,
                              highlightColor: shimmer["highlight"]!,
                              child: CircleAvatar(
                                // Create a circular avatar icon
                                radius: 36, // Set radius to 36
                                backgroundColor: swatch[900],
                              )),
                      imageBuilder: (final context, final imageProvider) =>
                          Container(
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
      ];

  Future<void> handlePop(final bool didPop, final Object? result) async {
    if (didPop) {
      return;
    }
    commonLogger.d("Popping with tab ${NavigationService.getCurrentIndex}");
    //final isFirstRouteInCurrentTabb = ;#
    if (mounted) {
      // let system handle back button if on the first route
      //final NavigatorState a = Navigator.of(context);
      final a = NavigationService.currentNavigatorKey.currentState;
      if (a!.canPop()) {
        a.pop();
        commonLogger.d("Popping");
      } else {
        commonLogger.d("Can't pop");
      }
      //navigator.pop();
    }

//    return isFirstRouteInCurrentTab;
  }

  @override
  Widget build(final BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
// This code returns a Consumer widget that rebuilds its child widget
// whenever the CurrentPage object changes.
    if (!gottenAvatar) {
      storage.getId().then((final value) => {
            value != null
                ? {
                    SocialAPI.getUser(value).then((final user) => {
                          mounted
                              ? setState(() {
                                  avatar = user["avatar_id"];
                                })
                              : null
                        }),
                    gottenAvatar = true
                  }
                : null
          });
    }
    commonLogger.d(backgroundImage.toString());
    return PopScope(
        canPop: false,
        // Handle user swiping back inside application
        onPopInvokedWithResult: handlePop,
        child: Consumer<NavigationService>(
            builder: (final context, final navigationService, final child) =>
                Scaffold(
                    extendBody: true,
                    bottomNavigationBar: Consumer<BottomBarVisibilityProvider>(
                      builder: (final context,
                              final bottomBarVisibilityProvider, final child) =>
                          AnimatedBuilder(
                        animation:
                            bottomBarVisibilityProvider.animationController,
                        builder: (final context, final child) {
                          final translateY = Tween<double>(
                            begin: bottomBarVisibilityProvider.isVisible
                                ? 0.0
                                : 1.0,
                            end: bottomBarVisibilityProvider.isVisible
                                ? 1.0
                                : 0.0,
                          )
                              .animate(bottomBarVisibilityProvider
                                  .animationController)
                              .value;

                          return Transform.translate(
                            offset: Offset(
                                0.0,
                                translateY *
                                    85.0), // Adjust the height as needed
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
                                              //initialActiveIndex: NavigationService.getCurrentIndex(), // Set initial selection to main page
                                              initialActiveIndex:
                                                  0, // Set initial selection to main page
                                              onTap: (final int i) => {
                                                //When a navbar button is pressed set the current tab to the tabitem that was pressed
                                                NavigationService
                                                    .setCurrentIndex(i),
                                                commonLogger.t(
                                                    "Setting the current page: $i")
                                              }, // When a button is pressed... output to console
                                              style: TabStyle
                                                  .fixedCircle, // Set the navbar style to have the circle stay at the centre
                                              backgroundColor:
                                                  const Color.fromARGB(184, 32,
                                                      49, 33), //swatch[51],
                                              activeColor: const Color.fromARGB(
                                                  51, 31, 175, 31),
                                              shadowColor: Colors.green,
                                              color: const Color.fromARGB(
                                                  51, 0, 23, 0),
                                              height: 55,
                                            ),
                                          ),
                                        ],
                                      )),
                          );
                        },
                      ),
                    ),
                    body: Stack(
                      children: [
                        SingleChildScrollView(
                            clipBehavior: Clip.none,
                            physics: const ClampingScrollPhysics(
                                parent: NeverScrollableScrollPhysics()),
                            child: Container(
                                constraints: BoxConstraints(
                                    minHeight:
                                        MediaQuery.of(context).size.height,
                                    minWidth:
                                        MediaQuery.of(context).size.width),
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: backgroundImage,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.center,
                                      colorFilter: ColorFilter.mode(
                                          Colors.black.withValues(alpha: 0.4),
                                          BlendMode.srcOver)),
                                ),
                                padding: const EdgeInsets.all(16))),
                        // Create a navigator stack for each item
                        _buildOffstageNavigator(0),
                        _buildOffstageNavigator(1),
                        _buildOffstageNavigator(2),
                        _buildOffstageNavigator(3),
                        _buildOffstageNavigator(4),
                      ],
                    )

                    // This trailing comma makes auto-formatting nicer for build methods.
                    )));
  }

  Widget _buildOffstageNavigator(final int tabItemIndex) => Offstage(
        offstage: NavigationService.getCurrentIndex != tabItemIndex,
        child: TabNavigator(
          tabItemIndex: tabItemIndex,
          tabitems: tabItems(),
        ),
      );
}

class Style extends StyleHook {
  @override
  double get iconSize => 50;

  @override
  double get activeIconMargin => 10;
  @override
  double get activeIconSize => 60;

  @override
  TextStyle textStyle(final Color color, final String? fontFamily) =>
      TextStyle(fontSize: 20, color: color);
}
