import 'package:flutter/material.dart';

class StopButton extends StatefulWidget {
  // Create HomePage Class
  const StopButton({Key? key})
      : super(key: key); // Take 2 arguments optional key and title of post
  @override
  State<StopButton> createState() =>
      _SpeedometerPage(); //Create state for widget
}

class _SpeedometerPage extends State<StopButton>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  @override
  void initState() {
    super.initState();

    // Create a new AnimationController
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    // Attach a listener to the controller
    controller.addListener(() {
      // Call setState() whenever the animation changes
      setState(() {});
    });
  }

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
        body: Center(
            // Center children
            child: GestureDetector(
                // Create basic gesture detector
                onTapDown: (details) {
                  // When held down
                  stopwatch.start(); // Start stopwatch
                  controller.forward(); // Play animation forward
                },
                onTapUp: (e) {
                  // When released
                  stopwatch.stop(); // Stop stopwatch
                  stopwatch.reset(); // Reset timer
                  var timeElapsedInSeconds = stopwatch.elapsed.inSeconds;
                  print("Time elapsed: $timeElapsedInSeconds");
                  if (controller.status == AnimationStatus.forward) {
                    controller.reverse(); // Reverse animation
                  }
                },
                child: Stack(
                  alignment: Alignment.center, // Fix alignment
                  // Create stack layout widget
                  children: [
                    const SizedBox(
                      // Wrap all children in sized box to enlarge button
                      height: 100,
                      width: 100,
                      child: CircularProgressIndicator(
                        // Create circular background
                        value: 1.0, // Set to full
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.grey), // Set colour to background colour
                      ),
                    ), // Add circular progress indicators
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: CircularProgressIndicator(
                        value: controller.value, // Set value to animation value
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blue), // Set fillin colour to blue for now
                      ),
                    ),
                    const SizedBox(
                        height: 100,
                        width: 100,
                        child: Icon(Icons.abc_outlined)) // Add temporary icon
                  ],
                ))));
  }
}
