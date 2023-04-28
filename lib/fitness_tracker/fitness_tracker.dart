import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:skating_app/fitness_tracker/save_session.dart';
import 'package:skating_app/fitness_tracker/speedometer.dart';
import 'package:solar_calculator/solar_calculator.dart';
import 'distance_travelled.dart';
import 'signal_strength_info.dart';
import 'package:skating_app/fitness_tracker/timer.dart';
import 'check_permission.dart';

class FitnessTracker extends StatefulWidget {
  const FitnessTracker({Key? key}) : super(key: key);
  @override
  State<FitnessTracker> createState() =>
      _FitnessTracker(); //Create state for widget
}

class _FitnessTracker extends State<FitnessTracker> {
  bool stoppedTracking = true;
  bool active = false;
  double totalDistance = 0;
  Position? previousPosition;
  late DateTime startTime;

  callback(double distance) {
    if (!stoppedTracking) {
      totalDistance = distance;
    }
    print(totalDistance);
  }

// This function calculates and retrieves the sunset time at a given position
  getSunsetTime(Position value) {
    // Get the current instant
    final instant = Instant.fromDateTime(DateTime.now());

    // Declare a variable to hold the SolarCalculator instance
    late SolarCalculator calc;

    // Create a new SolarCalculator instance with the given instant, latitude, and longitude
    calc = SolarCalculator(instant, value.latitude, value.longitude);

    // Retrieve the sunset time from the SolarCalculator instance and convert it to a DateTime object in the local timezone
    DateTime time = calc.sunsetTime.toUtcDateTime().toLocal();

    // Format the sunset time as a string with the format 'HH:mm' (hours:minutes)
    String formattedTime = DateFormat('HH:mm').format(time);

    // Set the state of the widget to display the formatted sunset time
    setState(() => {sunsetTime = formattedTime});
  }

  String sunsetTime = "00:00";
  String buttonMessage = "Start";

  @override
  void initState() {
    hasLocationPermission().then((value) => {
          Geolocator.getCurrentPosition()
              .then((position) => {getSunsetTime(position)})
        });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (active) {
      startTime = DateTime.now().toUtc();
    }
    // create an instance of the User class and passing it an id of '1'
    return Scaffold(
        // Scaffold widget, which is the basic layout element in Flutter
        body: Padding(
            // Padding widget to add padding around the edges of the screen
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(
                  flex: 50,
                ),
                Align(
                  alignment: Alignment
                      .centerLeft, // align widget to align button to left
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: IconButton(
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true).push(
                                // Send to signal info page
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SignalStrengthInfo())),
                        icon: const Icon(
                            Icons.signal_cellular_4_bar)), // placeholder icon
                  ),
                ),
                // Spacer widget with a flex of 1, which is used to take up any remaining space in the Column.

                Padding(
                  // Padding widget with smaller padding value, used to add padding around a nested Column widget
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(children: [
                    const Text("Distance Traveled"),
                    DistanceTravelled(active: active, callback: callback)
                  ]),
                ),
                Expanded(
                  flex: 100,
                  // used to take up any remaining space in the Column
                  child: Column(
                    children: [
                      Table(
                        // table that puts elements in a grid
                        children: [
                          TableRow(
                            // top row of table
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(children: [
                                  const Text("Session Duration"),
                                  active
                                      ? ClockWidget(
                                          startTime: DateTime
                                              .now() /*.subtract(
                                        Duration(minutes: 59, seconds: 50))*/
                                          ,
                                        )
                                      : const Text("0")
                                ]),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(children: const [
                                  Text("Avg. Session Duration"),
                                  Text("5:00")
                                ]),
                              ),
                            ],
                          ),
                          TableRow(
                            // bottom row of table
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(children: [
                                  const Text("Sunset Time"),
                                  Text(sunsetTime)
                                ]),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(children: const [
                                  Text("Average Speed"),
                                  Text("2kph")
                                ]),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // TextButton widget with a callback function to print "pressed" when clicked
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: TextButton(
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true).push(
                                  // Root navigator hides navbar
                                  // Send to speedometer page
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SpeedometerPage())),
                          child: const Text(
                              "Speedometer"), // Set text to speedometer
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  // callback function to print "pressed" when clicked
                  onPressed: () => {
                    setState(() {
                      active = !active;
                      buttonMessage = active ? "Stop" : "Start";
                      stoppedTracking = !stoppedTracking;
                    }),
                    if (!active)
                      {
                        Navigator.of(context, rootNavigator: true).push(
                            // Root navigator hides navbar
                            // Send to Save Session page
                            MaterialPageRoute(
                                builder: (context) => SaveSession(
                                      distance: totalDistance,
                                      startTime: startTime,
                                      endTime: DateTime.now(),
                                      callback: callback,
                                    ))),
                      }
                  },
                  child: Text(buttonMessage),
                ),

                const Spacer(
                  flex: 40,
                )
              ],
            )));
  }
}
