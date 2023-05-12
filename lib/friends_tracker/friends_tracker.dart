import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:skating_app/friends_tracker/friend_activity.dart';
import 'package:skating_app/friends_tracker/marker.dart';
import 'package:skating_app/objects/user.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:skating_app/api/session.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../current_tab.dart';

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
  const FriendsTrackerPage({Key? key})
      : super(key: key); // Take 2 arguments optional key and title of post

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
    getSessions().then((values) async => {
          // Get the list of sessions for each friend
          for (var session in values) // Loop through the sessions
            {
              userCache = await getUserCache(
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
            {setState(() => friends = newFriends)}
        });
    super.initState(); // Call the superclass's initState method
  }

  void updateSearchOpened(e) {
    setState(() => searchOpened = !e); // Update searchOpened state
  }

  @override
  void dispose() {
    _followOnLocationUpdate = FollowOnLocationUpdate.never;
    controller.dispose();
    _followCurrentLocationStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // create an instance of the User class and passing it an id of '1'
    print("build refind");

    bool isPortrait = true;
    return Scaffold(
        // Scaffold widget, which is the basic layout element in Flutter
        body: FlutterMap(
            mapController: controller,
            // Create flutter map
            options: MapOptions(
                interactiveFlags:
                    InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                center:
                    LatLng(51.509364, -0.128928), // Define Starting Position
                maxBounds: LatLngBounds(
                  // Prevent viewing off map
                  LatLng(-90, -180.0),
                  LatLng(90.0, 180.0),
                ),
                zoom: 15, // Set zoom factor
                minZoom: 3.0,
                maxZoom: 19),
            nonRotatedChildren: [
// Creates a FloatingSearchBar widget with specified properties
          FloatingSearchBar(
              // The text displayed as a placeholder in the search bar
              hint: AppLocalizations.of(context)!.search,

              // The padding around the search bar while scrolling
              scrollPadding: const EdgeInsets.only(top: 16, bottom: 40),

              // The duration of the animation when the search bar transitions between opened and closed states
              transitionDuration: const Duration(milliseconds: 800),

              // The curve used for the animation when the search bar transitions between opened and closed states
              transitionCurve: Curves.easeInOut,

              // The physics used for scrolling the search bar
              physics: const BouncingScrollPhysics(),

              // The alignment of the search bar along the x-axis
              axisAlignment: isPortrait ? 0.0 : -1.0,

              // The alignment of the search bar along the x-axis when it's in an open state
              openAxisAlignment: 0.0,

              // The width of the search bar
              width: isPortrait ? 600 : 500,

              // The delay in milliseconds before the onQueryChanged function is called
              debounceDelay: const Duration(milliseconds: 500),

              // A function that's called when the search query changes
              onQueryChanged: (query) {
                // Call your model, bloc, controller here.
              },

              // The custom transition to be used for animating between opened and closed states
              transition: CircularFloatingSearchBarTransition(),
              onFocusChanged: (e) =>
                  {updateSearchOpened(e), print(e)}, // Hide user list

              // An array of FloatingSearchBarAction widgets that provide actions within the search bar
              actions: [
                FloatingSearchBarAction(
                  showIfOpened: false,
                  child: CircularButton(
                    icon: const Icon(Icons.place),
                    onPressed: () {},
                  ),
                ),
                FloatingSearchBarAction.searchToClear(
                  showIfClosed: false,
                ),
              ],

              // A function that returns a widget that's displayed within the search bar
              builder: (context, transition) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Material(
                    color: Colors.white,
                    elevation: 4.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: Colors.accents.map((color) {
                        return Container(height: 100, color: color);
                      }).toList(),
                    ),
                  ),
                );
              }),
          AnimatedSwitcher(
              duration: const Duration(
                  milliseconds:
                      800), // Gradually fade back in when visible toggled
              switchOutCurve: const Interval(0.999, 1),
              child: searchOpened
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 72),
                      child: FriendActivity(
                          searchOpened: searchOpened, sessions: newSessions),
                    )
                  : Container()),

          // Default Attribution
          AttributionWidget.defaultWidget(
            source: 'OpenStreetMap',
            onSourceTapped: null,
          ),
          Positioned(
            // Position the widget to the bottom-right corner with a margin of 20 pixels.
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              // Triggered when the button is pressed.
              onPressed: () {
                // Update the widget state.
                setState(() => {
                      // Toggle the boolean value of the `active` variable.
                      active = !active,
                      // Set the `_followOnLocationUpdate` variable to either always or once based on the `active` variable.
                      _followOnLocationUpdate = active
                          ? FollowOnLocationUpdate.always
                          : FollowOnLocationUpdate.once,
                    });
                // If the `active` variable is true, add the zoom level (18) to the `_followCurrentLocationStreamController`.
                // If the `active` variable is false, do nothing.
                active ? _followCurrentLocationStreamController.add(18) : null;
              },
              child: const Icon(
                // Show the 'my location' icon on the button.
                Icons.my_location,
                // Set the color of the icon to white.
                color: Colors.white,
              ),
            ),
          ),
        ],
            children: [
          TileLayer(
            // Map source -- use OpenStreetMaps
            tileProvider: FMTC
                .instance('mapCache')
                .getTileProvider(), // For caching tiles to improve responsiveness
            maxZoom: 19,
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.skatingapp.map', // Package Name
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
        ]));
  }
}
