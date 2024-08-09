import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/friends_tracker/friend_activity.dart';
import 'package:patinka/friends_tracker/marker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:patinka/api/session.dart';
import 'package:provider/provider.dart';
import '../api/social.dart';
import '../current_tab.dart';
import './caching/map_cache.dart'
    if (dart.library.io) './caching/map_cache_mobile.dart'
    if (dart.library.html) './caching/map_cache_web.dart';
import './search_bar.dart';

bool searchOpened = true;
bool active = false;

/// Declare searchOpened variable

// Define a new StatelessWidget called FriendsTracker
class FriendsTracker extends StatelessWidget {
  // Constructor for FriendsTracker, which calls the constructor for its superclass (StatelessWidget)
  const FriendsTracker({super.key});

  // Override the build method of StatelessWidget to return a Consumer widget
  @override
  Widget build(BuildContext context) {
    // Use the Consumer widget to listen for changes to the CurrentPage object
    return Consumer<CurrentPage>(
      builder: (context, currentPage, widget) =>
          // If the CurrentPage's tab value is 3 (The friends tracker), return a FriendsTrackerPage widget
          currentPage.tab == 3
              ? const FriendsTrackerPage()
              :
              // Otherwise, return an empty SizedBox widget
              const SizedBox.shrink(),
    );
  }
}

class FriendsTrackerPage extends StatefulWidget {
  // Create FriendActivity widget
  const FriendsTrackerPage(
      {super.key}); // Take 2 arguments optional key and title of post

  @override
  State<FriendsTrackerPage> createState() =>
      _FriendsTrackerPage(); //Create state for widget
}

class _FriendsTrackerPage extends State<FriendsTrackerPage> {
  List<Map<String, dynamic>> newSessions = [];
  late MapController controller; // Controller for the map
  List<Marker> friends = []; // List of markers representing friends' locations
  late FollowOnLocationUpdate
      _followOnLocationUpdate; // Used to update the location of the user being followed
  late StreamController<double?>
      _followCurrentLocationStreamController; // Stream for updating the location of the user being followed
  @override
  void initState() {
    controller = MapController();
    _followOnLocationUpdate = FollowOnLocationUpdate
        .never; // Set the initial value for the follow update
    _followCurrentLocationStreamController = StreamController<
        double?>(); // Create the stream for updating the follow location
    List<Marker> newFriends =
        []; // Temporary list for storing the markers of the friends' locations
    Map<String, dynamic> userCache; // Cache for storing user information
    SessionAPI.getSessions().then((values) async => {
          // Get the list of sessions for each friend
          for (var session in values) // Loop through the sessions
            {
              userCache = await SocialAPI.getUser(
                  session["author"]), // Get the user information
              newFriends.add(
                // Add the marker for the friend's location to the temporary list
                Marker(
                    point: LatLng(session["latitude"], session["longitude"]),
                    width: 80,
                    height: 80,
                    builder: (context) => CustomMarker(
                        sessionData: session, userData: userCache)),
              ),
            },
          newSessions.addAll(values),
          if (newFriends
              .isNotEmpty) // If there are any new friends, update the state with the new list of markers
            {mounted ? setState(() => friends = newFriends) : null}
        });
    super.initState(); // Call the superclass's initState method
  }

  @override
  void dispose() {
    _followOnLocationUpdate = FollowOnLocationUpdate.never;
    controller.dispose();
    _followCurrentLocationStreamController.close();
    super.dispose();
  }

  BoxConstraints constraintsMax = const BoxConstraints(maxHeight: 0);

  @override
  Widget build(BuildContext context) {
    commonLogger.t("Building Map");
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxHeight > constraintsMax.maxHeight) {
        constraintsMax = constraints;
      }
      commonLogger.d(constraintsMax);
      return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          // Scaffold widget, which is the basic layout element in Flutter
          body: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraintsMax.maxWidth,
                minHeight: constraintsMax.maxHeight,
                maxWidth: constraintsMax.maxWidth,
                maxHeight: constraintsMax.maxHeight,
              ),
              child: FlutterMap(
                  mapController: controller,
                  // Create flutter map
                  options: MapOptions(
                      interactiveFlags:
                          InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                      center: LatLng(
                          51.509364, -0.128928), // Define Starting Position
                      maxBounds: LatLngBounds(
                        // Prevent viewing off map
                        LatLng(-90, -180.0),
                        LatLng(90.0, 180.0),
                      ),
                      zoom: 15, // Set zoom factor
                      minZoom: 3.0,
                      maxZoom: 19),
                  nonRotatedChildren: [
                    SafeArea(child: CustomSearchBar(mapController: controller)),

                    AnimatedSwitcher(
                        duration: const Duration(
                            milliseconds:
                                800), // Gradually fade back in when visible toggled
                        switchOutCurve: const Interval(0.999, 1),
                        child: searchOpened
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 72),
                                child: FriendActivity(
                                    searchOpened: searchOpened,
                                    sessions: newSessions),
                              )
                            : Container()),

                    // Default Attribution
                    // AttributionWidget.defaultWidget(
                    //   source: 'OpenStreetMap',
                    //   onSourceTapped: null,
                    // ),
                  ],
                  children: [
                    TileLayer(
                      panBuffer: 1,
                      backgroundColor: Colors.transparent,
                      // Map source -- use OpenStreetMaps
                      tileProvider:
                          tileProvider, // For caching tiles to improve responsiveness
                      maxZoom: 19,
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.skatingapp.map', // Package Name
                    ),
                    MarkerClusterLayerWidget(
                      // Define the options for the MarkerClusterLayer.
                      options: MarkerClusterLayerOptions(
                        // The maximum radius of a cluster.
                        maxClusterRadius: 45,
                        // The size of the marker icon for each cluster.
                        size: const Size(40, 40),
                        // The position of the anchor point for each marker icon.
                        anchor: AnchorPos.align(AnchorAlign.center),
                        // Options for fitting the map to the bounds of the markers.
                        fitBoundsOptions: const FitBoundsOptions(
                          // The padding to apply around the bounds of the markers.
                          padding: EdgeInsets.all(50),
                          // The maximum zoom level to use when fitting the map bounds.
                          maxZoom: 15,
                        ),
                        // The list of markers to cluster.
                        markers: friends,
                        // The builder function for creating the marker icon for each cluster.
                        builder: (context, markers) {
                          return Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.blue),
                            child: Center(
                              child: Text(
                                markers.length.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    CurrentLocationLayer(
                      followCurrentLocationStream:
                          _followCurrentLocationStreamController.stream,
                      followOnLocationUpdate: _followOnLocationUpdate,
                    ),
                  ]),
            ),
          ));
      // Positioned(
      //   // Position the widget to the bottom-right corner with a margin of 20 pixels.
      //   right: 20,
      //   bottom: 128,
      //   child: FloatingActionButton(
      //     // Triggered when the button is pressed.
      //     onPressed: () {
      //       // Update the widget state.
      //       mounted
      //           ? setState(() {
      //               // Toggle the boolean value of the `active` variable.
      //               active = !active;
      //               // Set the `_followOnLocationUpdate` variable to either always or once based on the `active` variable.
      //               _followOnLocationUpdate = active
      //                   ? FollowOnLocationUpdate.always
      //                   : FollowOnLocationUpdate.once;
      //             })
      //           : null;
      //       // If the `active` variable is true, add the zoom level (18) to the `_followCurrentLocationStreamController`.
      //       // If the `active` variable is false, do nothing.
      //       active ? _followCurrentLocationStreamController.add(18) : null;
      //     },
      //     child: const Icon(
      //       // Show the 'my location' icon on the button.
      //       Icons.my_location,
      //       // Set the color of the icon to white.
      //       color: Colors.white,
      //     ),
      //   ),
      // ),
      //);
    });
  }
}
