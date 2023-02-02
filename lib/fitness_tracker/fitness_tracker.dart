import 'package:flutter/material.dart';
import 'package:skating_app/fitness_tracker/speedometer.dart';
import 'package:skating_app/fitness_tracker/stop_button.dart';
import 'package:skating_app/objects/user.dart';
import 'signal_strength_info.dart';

class FitnessTracker extends StatelessWidget {
  // Constructor that takes a key and a title as required arguments
  const FitnessTracker({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    // create an instance of the User class and passing it an id of '1'
    User user = User("1");
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
                  child: Column(children: const [
                    Text("Distance Traveled"),
                    Text("0.0 Km")
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
                                child: Column(children: const [
                                  Text("Session Duration"),
                                  Text("47s")
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
                                child: Column(children: const [
                                  Text("Sunset Time"),
                                  Text("19:45")
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
                  onPressed: () => Navigator.of(context, rootNavigator: true)
                      .push(
                          // Root navigator hides navbar
                          // Send debug page
                          MaterialPageRoute(
                              builder: (context) => const StopButton())),
                  child: const Text("Start"),
                ),

                const Spacer(
                  flex: 40,
                )
              ],
            )));
  }
}
