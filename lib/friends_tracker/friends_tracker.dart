import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:flutter_map_location_marker/flutter_map_location_marker.dart";
//import "package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart";
import "package:latlong2/latlong.dart";
import "package:patinka/api/session.dart";
import "package:patinka/api/social.dart";
import "package:patinka/common_logger.dart";
// import "package:patinka/friends_tracker/caching/map_cache.dart"
//     if (dart.library.io) "./caching/map_cache_mobile.dart"
//     if (dart.library.html) "./caching/map_cache_web.dart";
import "package:patinka/friends_tracker/friend_activity.dart";
import "package:patinka/friends_tracker/marker.dart";
import "package:patinka/friends_tracker/search_bar.dart";
import "package:patinka/services/navigation_service.dart";
import "package:provider/provider.dart";

bool searchOpened = true;
bool active = false;

/// Declare searchOpened variable

// Define a new StatelessWidget called FriendsTracker
class FriendsTracker extends StatelessWidget {
  // Constructor for FriendsTracker, which calls the constructor for its superclass (StatelessWidget)
  const FriendsTracker({super.key});

  // Override the build method of StatelessWidget to return a Consumer widget
  @override
  Widget build(final BuildContext context) => Consumer<NavigationService>(
      builder: (final context, final navigationService, final _) =>
          NavigationService.getCurrentIndex == 3
              ? const FriendsTrackerPage()
              :
              // Otherwise, return an empty SizedBox widget
              const SizedBox.shrink());
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
  late AlignOnUpdate _followOnLocationUpdate; // Used to update the location of the user being followed
  late StreamController<LocationMarkerPosition>
      _followCurrentLocationStreamController; // Stream for updating the location of the user being followed
  @override
  void initState() {
    controller = MapController();
    _followOnLocationUpdate = AlignOnUpdate
        .never; // Set the initial value for the follow update
    _followCurrentLocationStreamController = StreamController<LocationMarkerPosition>(); // Create the stream for updating the follow location
    final List<Marker> newFriends =
        []; // Temporary list for storing the markers of the friends' locations
    Map<String, dynamic> userCache; // Cache for storing user information
    SessionAPI.getSessions().then((final values) async => {
          // Get the list of sessions for each friend
          for (final session in values) // Loop through the sessions
            {
              userCache = await SocialAPI.getUser(
                  session["author_id"]), // Get the user information
              newFriends.add(
                // Add the marker for the friend's location to the temporary list
                Marker(
                    key: Key(session["session_id"]),
                    point: const LatLng(
                        0, 0), //session["latitude"], session["longitude"]),
                    width: 80,
                    height: 80,
                    child: CustomMarker(
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
    //_followOnLocationUpdate = FollowOnLocationUpdate.never;
    controller.dispose();
    _followCurrentLocationStreamController.close();
    super.dispose();
  }

  BoxConstraints constraintsMax = const BoxConstraints(maxHeight: 0);

  void focusChangeCallback() {
    setState(() {
      searchOpened = !searchOpened;
    });
  }

  @override
  Widget build(final BuildContext context) {
    commonLogger.t("Building Map");
    return LayoutBuilder(builder: (final context, final constraints) {
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
              // child: const SizedBox.shrink()
              child: FlutterMap(
                  mapController: controller,
                  // Create flutter map
                  options: MapOptions(
                      // interactionOptions: InteractionOptions()
                      //     InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                      initialCenter: const LatLng(
                          51.509364, -0.128928), // Define Starting Position
                      cameraConstraint: CameraConstraint.contain(bounds: LatLngBounds(
                        // Prevent viewing off map
                        const LatLng(-90, -180.0),
                        const LatLng(90.0, 180.0),
                      ),),
                      initialZoom: 15, // Set zoom factor
                      minZoom: 3.0,
                      maxZoom: 19),
                    // Default Attribution
                    // AttributionWidget.defaultWidget(
                    //   source: 'OpenStreetMap',
                    //   onSourceTapped: null,
                    // ),
                  children: [
                    TileLayer(
                      panBuffer: 1,
                      //backgroundColor: Colors.transparent,
                      // Map source -- use OpenStreetMaps
                      //tileProvider:
                      //    tileProvider, // For caching tiles to improve responsiveness
                      maxZoom: 19,
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName:
                          "com.skatingapp.map", // Package Name
                    ),
                    // MarkerClusterLayerWidget(
                    //   // Define the options for the MarkerClusterLayer.
                    //   options: MarkerClusterLayerOptions(
                    //     // The maximum radius of a cluster.
                    //     maxClusterRadius: 45,
                    //     // The size of the marker icon for each cluster.
                    //     size: const Size(40, 40),
                    //     // The position of the anchor point for each marker icon.
                    //     anchor: AnchorPos.align(AnchorAlign.center),
                    //     // Options for fitting the map to the bounds of the markers.
                    //     fitBoundsOptions: const FitBoundsOptions(
                    //       // The padding to apply around the bounds of the markers.
                    //       padding: EdgeInsets.all(50),
                    //       // The maximum zoom level to use when fitting the map bounds.
                    //       maxZoom: 15,
                    //     ),
                    //     // The list of markers to cluster.
                    //     markers: friends,
                    //     // The builder function for creating the marker icon for each cluster.
                    //     builder: (final context, final markers) => DecoratedBox(
                    //       decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(20),
                    //           color: Colors.blue),
                    //       child: Center(
                    //         child: Text(
                    //           markers.length.toString(),
                    //           style: const TextStyle(color: Colors.white),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    MobileLayerTransformer(child: 
                    CurrentLocationLayer(
                      positionStream:
                          _followCurrentLocationStreamController.stream,
                      alignPositionOnUpdate: _followOnLocationUpdate,
                    ),),
                                        SafeArea(
                        child: CustomSearchBar(
                            mapController: controller,
                            focusChangeCallback: focusChangeCallback)),

                    AnimatedSwitcher(
                        duration: const Duration(
                            milliseconds:
                                800), // Gradually fade back in when visible toggled
                        switchOutCurve: const Interval(0.999, 1),
                        child: searchOpened
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 90),
                                child: FriendActivity(
                                    mapController: controller,
                                    searchOpened: searchOpened,
                                    sessions: newSessions),
                              )
                            : const SizedBox.shrink()),
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
