// Importing necessary packages
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../swatch.dart';
import 'check_permission.dart';

// Creating a stateful widget called DistanceTravelled
Position? previousPosition; // Initializing previous position as null

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
  StreamSubscription? stream;
  bool listening = true;

// Method to round off the value to specified number of decimal places
  double dp(double val, int places) {
    num mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  void updateDistance(difference) {
    double newDiff = totalDistance + difference;
    widget.callback(newDiff);
    setState(() {
      // Updating the total distance travelled
      totalDistance = newDiff;
    });
  }

  void createStream() {
    totalDistance = 0;
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
              updateDistance(difference);
            } else {
              totalDistance = 0;
            }
            // Updating the previous location
            previousPosition = position;
          }),
        });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.active) {
      if (stream == null) {
        createStream();
      }
// Checking if the location permission is granted or not

      // Calling the callback function with the total distance
      // Displaying the total distance in kilometers with 2 decimal places
      return DistanceTravelledText(
        totalDistance: totalDistance,
      );
    }
    stream?.cancel().then(
          (value) => {stream = null, print("asaaaaaa")},
        );
    previousPosition = null;
    return Text("0 Km", style: TextStyle(color: swatch[401]));
  }

  @override
  void dispose() {
    stream?.cancel();
    previousPosition = null;
    super.dispose();
  }
}

// Creating a stateful widget called DistanceTravelled
class DistanceTravelledText extends StatefulWidget {
  final double totalDistance;

  const DistanceTravelledText({Key? key, required this.totalDistance})
      : super(key: key);
  @override
  State<DistanceTravelledText> createState() =>
      _DistanceTravelledText(); //Creating state for the widget
}

// Creating a private state for the DistanceTravelled widget
class _DistanceTravelledText extends State<DistanceTravelledText> {
// Method to round off the value to specified number of decimal places
  double dp(double val, int places) {
    num mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }
  //widget.callback(totalDistance);

  @override
  Widget build(BuildContext context) {
    return Text(
      "${dp(widget.totalDistance / 1000, 2)} Km",
      style: TextStyle(color: swatch[401]),
    );
  }
}
