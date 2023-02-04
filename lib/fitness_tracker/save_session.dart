import 'package:flutter/material.dart';

class SaveSession extends StatefulWidget {
  // Create SaveSession Class
  const SaveSession({Key? key}) : super(key: key);
  @override
  State<SaveSession> createState() => _SaveSession(); //Create state for widget
}

class _SaveSession extends State<SaveSession> {
  @override // Override existing build method
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Create appBar
          leadingWidth: 48, // Remove extra leading space
          centerTitle: false, // Align title to left
          title: Title(
            title: "Save Session", //Set title to Save Session
            color: const Color(0xFFDDDDDD),
            child: const Text("Save Session"),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              // Split layout into individual rows
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center Children
                  // Top 2 elements
                  children: [
                    Container(
                      // Distance Traveled Box
                      margin: const EdgeInsets.all(8),
                      child: Column(
                        children: const [
                          Text("Distance Traveled"), // Title
                          Text("13km") // Value
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      // Session Duration Box
                      margin: const EdgeInsets.all(8),
                      child: Column(
                        children: const [
                          Text("Session Duration"), // Title
                          Text("1:03") // Value
                        ],
                      ),
                    )
                  ],
                ),
                const Text("Session Name"), // Session Name Infobox
                const Text(
                    "Session Description"), // Session Description Infobox
                const Text("Add Photos"), // Add Photos Infobox
                const Text("Type"), // Session Type Infobox
                const Text("Share To"), // Share to Infobox
                const Text("Save Session"), // Save Session Infobox
              ],
            )));
  }
}
