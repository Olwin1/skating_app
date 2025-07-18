import "package:flutter/material.dart";
import "package:geolocator/geolocator.dart";
import "package:intl/intl.dart";
import "package:patinka/api/config/config.dart";
import "package:patinka/caching/manager.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/fitness_tracker/check_permission.dart";
import "package:patinka/fitness_tracker/distance_travelled.dart";
import "package:patinka/fitness_tracker/save_session.dart";
import "package:patinka/fitness_tracker/signal_strength_info.dart";
import "package:patinka/fitness_tracker/speedometer.dart";
import "package:patinka/fitness_tracker/timer.dart";
import "package:patinka/l10n/app_localizations.dart";
import "package:patinka/services/navigation_service.dart";
import "package:patinka/swatch.dart";
import "package:provider/provider.dart";
import "package:solar_calculator/solar_calculator.dart";

String sunsetTime = "00:00";

class SunsetTime extends StatefulWidget {
  const SunsetTime({super.key});

  @override
  State<SunsetTime> createState() => _SunsetTimeState();
}

class _SunsetTimeState extends State<SunsetTime> {
  String time = "0:00";

  @override
  void initState() {
    NetworkManager.instance
        .getLocalData(name: "cache-sunset", type: CacheTypes.misc)
        .then((final String? localData) {
      if (localData != null) {
        final String tmpTime = localData.substring(1, localData.length - 1);
        mounted ? setState(() => time = tmpTime) : time = tmpTime;
      }
    });
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    bool setted = false;
    void setSetted() {
      setted = true;
    }

    return Consumer<NavigationService>(
        builder: (final context, final navigationService, final _) => NavigationService.getCurrentIndex == 1
          ? SunsetTimeWidget(time: time, setted: setted, setSetted: setSetted)
          : const Text("0:00"));
  }
}

class SunsetTimeWidget extends StatefulWidget {
  const SunsetTimeWidget(
      {required this.time, required this.setted, required this.setSetted, super.key});
  final String time;
  final bool setted;
  final VoidCallback setSetted;
  @override
  State<SunsetTimeWidget> createState() =>
      _SunsetTimeWidget(); //Create state for widget
}

class _SunsetTimeWidget extends State<SunsetTimeWidget> {
  String sunsetTime = "0:00";
  @override
  void initState() {
    if (!widget.setted) {
      hasLocationPermission().then((final value) => {
            Geolocator.getCurrentPosition()
                .then((final position) => {getSunsetTime(position)})
          });
      widget.setSetted();
    }

    super.initState();
  }

  // This function calculates and retrieves the sunset time at a given position
  void getSunsetTime(final Position value) {
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
    final DateTime time = calc.sunsetTime.toUtcDateTime().toLocal();

    // Format the sunset time as a string with the format 'HH:mm' (hours:minutes)
    final String formattedTime = DateFormat("HH:mm").format(time);
    NetworkManager.instance.saveData(
        name: "cache-sunset", type: CacheTypes.misc, data: formattedTime);

    // Set the state of the widget to display the formatted sunset time
    mounted ? setState(() => sunsetTime = formattedTime) : null;
  }

  @override
  Widget build(final BuildContext context) {
    if (sunsetTime == "0:00") {
      sunsetTime = widget.time;
    }
    return Text(sunsetTime, style: TextStyle(color: swatch[401]));
  }
}

class FitnessTracker extends StatefulWidget {
  const FitnessTracker({super.key});
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

  void callback(final double distance) {
    if (!stoppedTracking) {
      totalDistance = distance;
    }
    commonLogger.d("Total distance is: $totalDistance");
  }

  String buttonMessage = "Start";

  @override
  Widget build(final BuildContext context) {
    if (active) {
      buttonMessage = AppLocalizations.of(context)!.stop;
      startTime = DateTime.now().toUtc();
    } else {
      buttonMessage = AppLocalizations.of(context)!.start;
    }
    // create an instance of the User class and passing it an id of '1'
    return Scaffold(
        backgroundColor: Colors.transparent,
        // Scaffold widget, which is the basic layout element in Flutter
        body: Container(
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
                        color: Colors.transparent, //? Remember to remove this
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true).push(
                                // Send to signal info page
                                MaterialPageRoute(
                                    builder: (final context) =>
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
                          onPressed: () => Navigator.of(context).push(
                            // Root navigator hides navbar
                            // Send to speedometer page
                            PageRouteBuilder(
                              pageBuilder:
                                  (final context, final animation, final secondaryAnimation) =>
                                      const SpeedometerPage(),
                              opaque: false,
                              transitionsBuilder: (final context, final animation,
                                  final secondaryAnimation, final child) {
                                const begin = 0.0;
                                const end = 1.0;
                                final tween = Tween(begin: begin, end: end);
                                final fadeAnimation = tween.animate(animation);
                                return FadeTransition(
                                  opacity: fadeAnimation,
                                  child: child,
                                );
                              },
                            ),
                          ),
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
                        Navigator.of(context).push(
                            // Root navigator hides navbar
                            // Send to Save Session page
                            MaterialPageRoute(
                                builder: (final context) => SaveSession(
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
                            .then((final value) => initialPosition = value)
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
