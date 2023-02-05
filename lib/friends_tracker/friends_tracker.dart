import 'package:flutter/material.dart';
import 'package:skating_app/objects/user.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FriendsTracker extends StatelessWidget {
  // Constructor that takes a key and a title as required arguments
  const FriendsTracker({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    // create an instance of the User class and passing it an id of '1'
    User user = User("1");
    return Scaffold(
        // Scaffold widget, which is the basic layout element in Flutter
        body: FlutterMap(
      // Create flutter map
      options: MapOptions(
        center: LatLng(51.509364, -0.128928), // Define Starting Position
        zoom: 15, // Set zoom factor
      ),
      nonRotatedChildren: [
        // Default Attribution
        AttributionWidget.defaultWidget(
          source: 'OpenStreetMap contributors',
          onSourceTapped: null,
        ),
      ],
      children: [
        TileLayer(
          // Map source -- use OpenStreetMaps
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.skatingapp.map', // Package Name
        ),
      ],
    ));
  }
}
