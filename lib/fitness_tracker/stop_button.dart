import 'package:flutter/material.dart';

class StopButton extends StatefulWidget {
  // Create HomePage Class
  const StopButton({Key? key})
      : super(key: key); // Take 2 arguments optional key and title of post
  @override
  State<StopButton> createState() =>
      _SpeedometerPage(); //Create state for widget
}

class _SpeedometerPage extends State<StopButton> {
  @override // Override existing build method
  Widget build(BuildContext context) {
    Stopwatch stopwatch = Stopwatch(); // Create stopwatch object
    return Scaffold(
        appBar: AppBar(
          // Create appBar
          leadingWidth: 48, // Remove extra leading space
          centerTitle: false, // Align title to left
          title: Title(
            title: "Speedometer", //Set title to Speedometer
            color: const Color(0xFFDDDDDD),
            child: const Text("Speedometer"),
          ),
        ),
        body: GestureDetector(
          // Create basic gesture detector
          onLongPressDown: (details) {
            // When held down
            stopwatch.start(); // Start stopwatch
          },
          onLongPressUp: () {
            // When released
            stopwatch.stop(); // Stop stopwatch
            var timeElapsedInSeconds = stopwatch.elapsed.inSeconds;
            print("Time elapsed: $timeElapsedInSeconds");
          },
        ));
  }
}
