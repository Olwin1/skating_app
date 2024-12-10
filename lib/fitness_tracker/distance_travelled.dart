// Importing necessary packages
import "dart:async";
import "dart:math";

import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/fitness_tracker/check_permission.dart";
import "package:patinka/swatch.dart";

// Creating a stateful widget called DistanceTravelled
Position? previousPosition; // Initializing previous position as null

class DistanceTravelled extends StatefulWidget {
  const DistanceTravelled(
      {required this.active, required this.callback, super.key});
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
  double dp(final double val, final int places) {
    final num mod = pow(10.0, places);
    return (val * mod).round().toDouble() / mod;
  }

  void updateDistance(final double difference) {
    final double newDiff = totalDistance + difference;
    widget.callback(newDiff);
    mounted
        ? setState(() {
            // Updating the total distance travelled
            totalDistance = newDiff;
          })
        : null;
  }

  void createStream() {
    totalDistance = 0;
    hasLocationPermission().then((final value) => {
// Getting the position stream and listening for any changes in the location
          stream = Geolocator.getPositionStream().listen((final position) {
            if (previousPosition != null) {
// Calculating the distance travelled from the previous location
              final double difference = Geolocator.distanceBetween(
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
  Widget build(final BuildContext context) {
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
          (final value) => {stream = null, commonLogger.t("Cancelling stream")},
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
  const DistanceTravelledText({required this.totalDistance, super.key});
  final double totalDistance;
  @override
  State<DistanceTravelledText> createState() =>
      _DistanceTravelledText(); //Creating state for the widget
}

// Creating a private state for the DistanceTravelled widget
class _DistanceTravelledText extends State<DistanceTravelledText> {
// Method to round off the value to specified number of decimal places
  double dp(final double val, final int places) {
    final num mod = pow(10.0, places);
    return (val * mod).round().toDouble() / mod;
  }
  //widget.callback(totalDistance);

  @override
  Widget build(final BuildContext context) => Text(
        "${dp(widget.totalDistance / 1000, 2)} Km",
        style: TextStyle(color: swatch[401]),
      );
}
