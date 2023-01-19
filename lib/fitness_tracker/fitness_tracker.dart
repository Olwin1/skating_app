import 'package:flutter/material.dart';
import 'package:skating_app/objects/user.dart';

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
                // Spacer widget with a flex of 1, which is used to take up any remaining space in the Column.
                const Spacer(
                  flex: 1,
                ),
                Padding(
                  // Padding widget with smaller padding value, used to add padding around a nested Column widget
                  padding: const EdgeInsets.all(32),
                  child: Column(children: const [
                    Text("Distance Traveled"),
                    Text("0.0 Km")
                  ]),
                ),
                Expanded(
                  // used to take up any remaining space in the Column
                  child: GridView.count(
                    // padding around the grid
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    // number of columns in the grid
                    crossAxisCount: 2,
                    children: [
                      Column(children: const [
                        Text("Session Duration"),
                        Text("47s")
                      ]),
                      Column(children: const [
                        Text("Average Session Duration"),
                        Text("5:00")
                      ]),
                      Column(
                          children: const [Text("Sunset Time"), Text("19:45")]),
                      Column(children: const [
                        Text("Average Speed"),
                        Text("2kph")
                      ]),
                    ],
                  ),
                ),
                // TextButton widget with a callback function to print "pressed" when clicked
                TextButton(
                  onPressed: () => print("pressed"),
                  child: const Text("Speedometer"),
                ),
                Padding(
                  // Padding widget to add padding around the button
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: TextButton(
                    // callback function to print "pressed" when clicked
                    onPressed: () => print("pressed"),
                    child: const Text("Start"),
                  ),
                )
              ],
            )));
  }
}
