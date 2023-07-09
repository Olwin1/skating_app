import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:skating_app/common_logger.dart';
import 'package:skating_app/fitness_tracker/save_session.dart';
import 'package:skating_app/fitness_tracker/speedometer.dart';
import 'package:solar_calculator/solar_calculator.dart';
import '../swatch.dart';
import 'distance_travelled.dart';
import 'signal_strength_info.dart';
import 'package:skating_app/fitness_tracker/timer.dart';
import 'check_permission.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../current_tab.dart';

String sunsetTime = "00:00";

class SunsetTime extends StatelessWidget {
  const SunsetTime({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentPage>(
      builder: (context, currentPage, widget) =>
          // If the CurrentPage's tab value is 4 (The fitness tracker page), return a Sunset time widget
          currentPage.tab == 1 ? const SunsetTimeWidget() : const Text("0:00"),
    );
  }
}

class SunsetTimeWidget extends StatefulWidget {
  const SunsetTimeWidget({Key? key}) : super(key: key);
  @override
  State<SunsetTimeWidget> createState() =>
      _SunsetTimeWidget(); //Create state for widget
}

class _SunsetTimeWidget extends State<SunsetTimeWidget> {
  @override
  void initState() {
    hasLocationPermission().then((value) => {
          Geolocator.getCurrentPosition()
              .then((position) => {getSunsetTime(position)})
        });

    super.initState();
  }

  // This function calculates and retrieves the sunset time at a given position
  getSunsetTime(Position value) {
    if (!mounted) {
      return;
    }

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
    mounted ? setState(() => sunsetTime = formattedTime) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Text(sunsetTime, style: TextStyle(color: swatch[401]));
  }
}

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
  Position? initialPosition;
  Position? previousPosition;
  late DateTime startTime;

  callback(double distance) {
    if (!stoppedTracking) {
      totalDistance = distance;
    }
    commonLogger.d("Total distance is: $totalDistance");
  }

  String buttonMessage = "Start";

  @override
  Widget build(BuildContext context) {
    if (active) {
      buttonMessage = AppLocalizations.of(context)!.stop;
      startTime = DateTime.now().toUtc();
    } else {
      buttonMessage = AppLocalizations.of(context)!.start;
    }
    // create an instance of the User class and passing it an id of '1'
    return Scaffold(
        // Scaffold widget, which is the basic layout element in Flutter
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: const AssetImage("assets/backgrounds/graffiti.png"),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5), BlendMode.srcOver)),
            ),
            // Padding widget to add padding around the edges of the screen
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(
                  flex: 45,
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
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(125, 0, 0, 0),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Column(children: [
                        Text(AppLocalizations.of(context)!.distanceTraveled,
                            style: TextStyle(color: swatch[601])),
                        DistanceTravelled(active: active, callback: callback)
                      ])),
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
                              Container(
                                margin: const EdgeInsets.all(4),
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                    color: Color.fromARGB(125, 0, 0, 0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                child: Column(children: [
                                  Text(
                                      AppLocalizations.of(context)!
                                          .sessionDuration,
                                      style: TextStyle(color: swatch[601])),
                                  active
                                      ? ClockWidget(
                                          startTime: DateTime
                                              .now() /*.subtract(
                                        Duration(minutes: 59, seconds: 50))*/
                                          ,
                                        )
                                      : Text("0",
                                          style: TextStyle(color: swatch[401]))
                                ]),
                              ),
                              Container(
                                margin: const EdgeInsets.all(4),
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                    color: Color.fromARGB(125, 0, 0, 0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                child: Column(children: [
                                  Text(
                                      AppLocalizations.of(context)!
                                          .averageSessionDuration,
                                      style: TextStyle(color: swatch[601])),
                                  Text("5:00",
                                      style: TextStyle(color: swatch[401]))
                                ]),
                              ),
                            ],
                          ),
                          TableRow(
                            // bottom row of table
                            children: [
                              Container(
                                margin: const EdgeInsets.all(4),
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                    color: Color.fromARGB(125, 0, 0, 0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                child: Column(children: [
                                  Text(AppLocalizations.of(context)!.sunsetTime,
                                      style: TextStyle(color: swatch[601])),
                                  const SunsetTime()
                                ]),
                              ),
                              Container(
                                margin: const EdgeInsets.all(4),
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                    color: Color.fromARGB(125, 0, 0, 0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                child: Column(children: [
                                  Text(
                                      AppLocalizations.of(context)!
                                          .averageSpeed,
                                      style: TextStyle(color: swatch[601])),
                                  Text("2kph",
                                      style: TextStyle(color: swatch[401]))
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
                          child: Text(
                            AppLocalizations.of(context)!.speedometer,
                            style: TextStyle(color: swatch[201], fontSize: 15),
                          ), // Set text to speedometer
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  // callback function to print "pressed" when clicked
                  onPressed: () => {
                    mounted
                        ? setState(() {
                            active = !active;
                            buttonMessage = active
                                ? AppLocalizations.of(context)!.stop
                                : AppLocalizations.of(context)!.start;
                            stoppedTracking = !stoppedTracking;
                          })
                        : null,
                    if (!active && initialPosition != null)
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
                                      initialPosition: initialPosition!,
                                    ))),
                      }
                    else
                      {
                        Geolocator.getCurrentPosition()
                            .then((value) => initialPosition = value)
                      }
                  },
                  child: Text(buttonMessage,
                      style: TextStyle(
                          color: swatch[701],
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                ),

                const Spacer(
                  flex: 40,
                )
              ],
            )));
  }
}
