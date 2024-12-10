import "package:flutter/material.dart";
import "package:patinka/fitness_tracker/signal_strength_object.dart";

class SignalStrengthInfo extends StatefulWidget {
  // Create HomePage Class
  const SignalStrengthInfo(
      {super.key}); // Take 2 arguments optional key and title of post
  @override
  State<SignalStrengthInfo> createState() =>
      _SignalStrengthInfo(); //Create state for widget
}

class _SignalStrengthInfo extends State<SignalStrengthInfo> {
  @override // Override existing build method
  Widget build(final BuildContext context) => Scaffold(
      appBar: AppBar(
        // Create appBar
        leadingWidth: 48, // Remove extra leading space
        centerTitle: false, // Align title to left
        title: Title(
          title: "SignalStrengthInfo", //Set title to Signal Strength Info
          color: const Color(0xFFDDDDDD),
          child: const Text("SignalStrengthInfo"),
        ),
      ),
      body: const Column(children: [
        Text(// Placeholder page purpose description
            """
Your GPS signal strength is visible throughout your sessions.
            The stronger the signal the more accurate the tracking can be.
            Use this info to understand how accurate your tracking is."""),
        SignalStrengthObject(
          // Create strong GPS signal strength widget
          title: "Strong",
          body: "Strong GPS signal tracking results are optimal.",
        ), // What each icon means
        SignalStrengthObject(
          // Create good GPS signal strength widget
          title: "Good",
          body:
              "Good GPS signal tracking results will have a standard level of accuracy.",
        ),
        SignalStrengthObject(
          // Create acceptable GPS signal strength widget
          title: "Acceptable",
          body:
              "Acceptable GPS signal tracking. Results will have an adequate level of accuracy.",
        ),
        SignalStrengthObject(
          // Create low GPS signal strength widget
          title: "Low",
          body:
              "Low GPS signal. Tracking results may not be accurate without a stronger signal.",
        ),
        SignalStrengthObject(
          // Create poor GPS signal strength widget
          title: "Poor",
          body:
              "Poor GPS signal move to a area with a stronger signal for better tracking results.",
        ),
      ]),
    );
}
