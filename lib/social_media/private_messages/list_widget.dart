import 'package:flutter/material.dart';

class ListWidget extends StatefulWidget {
  // Create HomePage Class
  const ListWidget({Key? key, required this.index})
      : super(key: key); // Take 2 arguments optional key and title of post
  final int index; // Define title argument
  @override
  State<ListWidget> createState() => _ListWidget(); //Create state for widget
}

class _ListWidget extends State<ListWidget> {
  @override // Override existing build method
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(8), // Add padding so doesn't touch edges
      color: const Color(0xFFFFE306), // For testing to highlight seperations
      child: TextButton(
        // Make list widget clickable
        onPressed: () => print("pressed"), //When list widget clicked
        child: Row(
          // Create a row
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Add List image to one row and buttons to another
            const CircleAvatar(
              // Create a circular avatar icon
              radius: 30, //Set radius to 30
              backgroundImage: AssetImage(
                  "assets/placeholders/150.png"), // Set avatar to placeholder images
            ),
            const Padding(
                padding:
                    EdgeInsets.only(left: 16)), // Space between avatar and text
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  // Create a column aligned to the left
                  Padding(
                    //Add padding to the top to move the text down a bit
                    padding: EdgeInsets.only(top: 10),
                  ),
                  Text(
                    //Message target's Name
                    "Friend 1",
                  ),
                  Text("Last message sent · 4h",
                      style: TextStyle(
                          color: Color.fromARGB(
                              255, 77, 77, 77), // Set colour to light grey
                          height: 1.5)), // Last message sent from user
                ]),
          ],
        ),
      ),
    );
  }
}
