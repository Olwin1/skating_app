import 'package:flutter/material.dart';
import 'package:alxgration_speedometer/speedometer.dart';
import 'package:bezier_chart/bezier_chart.dart';

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
          const Spacer(),
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
          Container(
            // Create container widget'
            color: Colors.red, // Set background colour to red to see boundaries
            height: MediaQuery.of(context).size.height /
                2, // Define size of container
            width: MediaQuery.of(context).size.width * 0.9,
            child: BezierChart(
              // Create bezier chart
              bezierChartScale: BezierChartScale.CUSTOM,
              xAxisCustomValues: const [
                0,
                5,
                10,
                15,
                20,
                25,
                30,
                35
              ], // Set X axis values
              series: const [
                // Define testing datapoints
                BezierLine(
                  data: [
                    DataPoint<double>(value: 10, xAxis: 0),
                    DataPoint<double>(value: 130, xAxis: 5),
                    DataPoint<double>(value: 50, xAxis: 10),
                    DataPoint<double>(value: 150, xAxis: 15),
                    DataPoint<double>(value: 75, xAxis: 20),
                    DataPoint<double>(value: 0, xAxis: 25),
                    DataPoint<double>(value: 5, xAxis: 30),
                    DataPoint<double>(value: 45, xAxis: 35),
                  ],
                ),
              ],
              config: BezierChartConfig(
                verticalIndicatorStrokeWidth: 3.0,
                verticalIndicatorColor: Colors.black26,
                showVerticalIndicator: true,
                backgroundColor: Colors.red, // For debugging
                snap: false, // Don't snap between each data point
              ),
            ),
          ),
        ]));
  }
}
