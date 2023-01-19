import 'package:flutter/material.dart';
import 'signal_strength_object.dart';

class SignalStrengthInfo extends StatefulWidget {
  // Create HomePage Class
  const SignalStrengthInfo({Key? key})
      : super(key: key); // Take 2 arguments optional key and title of post
  @override
  State<SignalStrengthInfo> createState() =>
      _SignalStrengthInfo(); //Create state for widget
}

class _SignalStrengthInfo extends State<SignalStrengthInfo> {
  late FocusNode focus; // Define focus node
  @override // Override existing build method
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Column(children: const [
        Text(// Placeholder page purpose description
            """Your GPS signal strength is visible throughout your sessions.
            The stronger the signal the more accurate the tracking can be.
            Use this info to understand how accurate your tracking is."""),
        SignalStrengthObject(), // What each icon means
        SignalStrengthObject(),
        SignalStrengthObject(),
      ]),
    );
  }
}
