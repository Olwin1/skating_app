// Importing necessary packages
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'check_permission.dart';

// Creating a stateful widget called DistanceTravelled
class DistanceTravelled extends StatefulWidget {
  const DistanceTravelled(
      {Key? key, required this.active, required this.callback})
      : super(key: key);
  final bool active;
  final Function callback;
  @override
  State<DistanceTravelled> createState() =>
      _DistanceTravelled(); //Creating state for the widget
}

// Creating a private state for the DistanceTravelled widget
class _DistanceTravelled extends State<DistanceTravelled> {
  double totalDistance = 0; // Initial distance is set to 0
  Position? previousPosition; // Initializing previous position as null
  StreamSubscription? stream;

// Method to round off the value to specified number of decimal places
  double dp(double val, int places) {
    num mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.active) {
// Checking if the location permission is granted or not
      hasLocationPermission().then((value) => {
// Getting the position stream and listening for any changes in the location
            stream = Geolocator.getPositionStream().listen((position) {
              if (previousPosition != null) {
// Calculating the distance travelled from the previous location
                double difference = Geolocator.distanceBetween(
                    previousPosition!.latitude,
                    previousPosition!.longitude,
                    position.latitude,
                    position.longitude);
                setState(() {
                  // Updating the total distance travelled
                  totalDistance += difference;
                });
              }
              // Updating the previous location
              previousPosition = position;
            })
          });
      // Calling the callback function with the total distance
      widget.callback(totalDistance);
      // Displaying the total distance in kilometers with 2 decimal places
      return Text("${dp(totalDistance / 1000, 2)} Km");
    } else {
      stream?.cancel();
      // Displaying 0.0 km if the widget is not active
      return const Text("0.0 km");
    }
  }
}
