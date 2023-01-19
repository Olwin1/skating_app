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
                const Spacer(
                  flex: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(32), // Add padding
                  child: Column(children: const [
                    Text("Distance Traveled"), // Distance Traveled Header
                    Text("0.0 Km") // Distance Traveled Data
                  ]),
                ), // Distance traveled
                Expanded(
                  child: GridView.count(
                    // Create Basic Gridview
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    crossAxisCount: 2, // Set width to 2 widgets
                    children: [
                      Column(children: const [
                        Text("Session Duration"), // Session Duration Header
                        Text("47s") // Session duration Data
                      ]),
                      Column(children: const [
                        Text(
                            "Average Session Duration"), // Average Session Duration Header
                        Text("5:00") // Average Session duration Data
                      ]),
                      Column(children: const [
                        Text("Sunset Time"), // Sunset Time Header
                        Text("19:45") // Sunset Time Data
                      ]),
                      Column(children: const [
                        Text("Average Speed"), // Average Speed Header
                        Text("2kph") // Session duration Data
                      ]),
                    ],
                  ),
                ),
                TextButton(
                  // Create speedometer button
                  onPressed: () => print("pressed"), // When pressed
                  child: const Text("Speedometer"), // Speedometer filler text
                ), // Speedometer button
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 32), // Add padding to space away from rest
                  child: TextButton(
                    onPressed: () => print("pressed"),
                    child: const Text("Start"), // Filler text
                  ),
                ) // Start Button
              ],
            )));
  }
}
