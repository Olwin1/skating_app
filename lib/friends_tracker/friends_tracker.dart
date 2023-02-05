import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skating_app/objects/user.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class FriendsTracker extends StatelessWidget {
  // Constructor that takes a key and a title as required arguments
  const FriendsTracker({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    // create an instance of the User class and passing it an id of '1'
    User user = User("1");
    bool isPortrait = true;
    return Scaffold(
      // Scaffold widget, which is the basic layout element in Flutter
      body: FlutterMap(
        // Create flutter map
        options: MapOptions(
            center: LatLng(51.509364, -0.128928), // Define Starting Position
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
              hint: 'Search...',

              // The padding around the search bar while scrolling
              scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),

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
                        return Container(height: 112, color: color);
                      }).toList(),
                    ),
                  ),
                );
              }),

          // Default Attribution
          AttributionWidget.defaultWidget(
            source: 'OpenStreetMap contributors',
            onSourceTapped: null,
          ),
        ],
        children: [
          TileLayer(
            // Map source -- use OpenStreetMaps
            maxZoom: 19,
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.skatingapp.map', // Package Name
          ),
        ],
      ),
    );
  }
}
