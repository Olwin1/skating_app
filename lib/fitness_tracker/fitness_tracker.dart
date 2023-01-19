import 'package:flutter/material.dart';
import 'package:skating_app/objects/user.dart';

class FitnessTracker extends StatelessWidget {
  // Create FitnessTracker Class
  const FitnessTracker({Key? key, required this.title}) : super(key: key);
  final String title; // Define title argument

  @override // Override the existing widget build method
  Widget build(BuildContext context) {
    User user = User("1"); // Create user object with id of 1
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              // Create basic vertical layout
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8), // Add padding
                  child: Column(children: const [
                    Text("Distance Traveled"), // Distance Traveled Header
                    Text("0.0 Km") // Distance Traveled Data
                  ]),
                ), // Distance traveled
                Expanded(
                  child: GridView.count(
                    // Create Basic Gridview
                    crossAxisCount: 2, // Set width to 2 widgets
                    children: [
                      Container(),
                      Container(),
                      Container(),
                      Container()
                    ],
                  ),
                ),
                Container(), // Speedometer button
                Container() // Start Button
              ],
            )));
  }
}
