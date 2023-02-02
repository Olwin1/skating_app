import 'package:flutter/material.dart';
import 'package:alxgration_speedometer/speedometer.dart';
import 'package:fl_chart/fl_chart.dart';

class SpeedometerPage extends StatefulWidget {
  // Create HomePage Class
  const SpeedometerPage({Key? key})
      : super(key: key); // Take 2 arguments optional key and title of post
  @override
  State<SpeedometerPage> createState() =>
      _SpeedometerPage(); //Create state for widget
}

class _SpeedometerPage extends State<SpeedometerPage> {
  @override // Override existing build method
  Widget build(BuildContext context) {
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
        body: Column(children: [
          Spacer(),
          Speedometer(
            // Create speedometer widget
            size: 300, // Set size to 200
            minValue: 0, // Define min and max values
            maxValue: 10,
            currentValue: 5, // Set current speed
            barColor: Colors.purple, // Set bar and pointer colours
            pointerColor: Colors.black,
            displayText: "km/h", // Define unit
            displayTextStyle: const TextStyle(
                fontSize: 14, color: Colors.deepOrange), // Text colour
            displayNumericStyle:
                const TextStyle(fontSize: 24, color: Colors.red),
            onComplete: () {
              print("ON COMPLETE");
            },
          ),
          Spacer(
            flex: 2,
          )
        ]));
  }
}
