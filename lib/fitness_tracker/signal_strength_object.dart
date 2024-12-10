import "package:flutter/material.dart";

class SignalStrengthObject extends StatefulWidget {
  // Create HomePage Class
  const SignalStrengthObject(
      {required this.title, required this.body, super.key}); // Take optional key
  final String title; // Take title and body arguments as strings
  final String body;

  @override
  State<SignalStrengthObject> createState() =>
      _SignalStrengthObject(); //Create state for widget
}

class _SignalStrengthObject extends State<SignalStrengthObject> {
  @override // Override existing build method
  Widget build(final BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(
          vertical:
              16), // Add vertical padding of 16 logical pixels to space each row
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align with left
        children: [
          const Padding(
            // Add padding of 8 logical pixels
            padding: EdgeInsets.all(8),
            child: Icon(Icons.signal_cellular_0_bar), // Set to placeholder icon
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align with left
            children: [
              Text(
                widget.title, // Use title argument passed
                style: const TextStyle(
                    fontSize:
                        16), // Make font size 2 pixels larger than default
              ),
              Text(widget.body) // Use body argument passed
            ],
          ))
        ],
      ),
    );
}
