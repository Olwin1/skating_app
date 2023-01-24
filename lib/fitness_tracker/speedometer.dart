import 'package:flutter/material.dart';

class Speedometer extends StatefulWidget {
  // Create HomePage Class
  const Speedometer({Key? key})
      : super(key: key); // Take 2 arguments optional key and title of post
  @override
  State<Speedometer> createState() => _Speedometer(); //Create state for widget
}

class _Speedometer extends State<Speedometer> {
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
        body: Column(
          children: const [],
        ));
  }
}
