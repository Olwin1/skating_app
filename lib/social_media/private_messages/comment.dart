import 'package:flutter/material.dart';

class Comment extends StatefulWidget {
  // Create HomePage Class
  const Comment({Key? key, required this.index, this.focus})
      : super(key: key); // Take 2 arguments optional key and title of post
  final int index; // Define title argument
  final FocusNode? focus; // Define focus argument
  @override
  State<Comment> createState() => _Comment(); //Create state for widget
}

class _Comment extends State<Comment> {
  @override // Override existing build method
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4), // Add padding so doesn't touch edges
      child: TextButton(
        onPressed: () => print("Pressed"),
        // Make list widget clickable
        onLongPress: () => print("longPress"), //When list widget clicked
        child: Row(
          // Create Row
          children: [
            const Padding(
              padding: EdgeInsets.only(
                // Only give right of avatar padding
                right: 8,
              ),
              child: CircleAvatar(
                //Put avatar on left
                // Create a circular avatar icon
                radius: 25, //Set radius to 20
                backgroundImage: AssetImage(
                    "assets/placeholders/150.png"), // Set avatar to placeholder images
              ),
            ),
            Expanded(
                // Expanded Widget Wrapper
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Put rest on right
                  children: [
                    Row(
                      // Create top row
                      children: const [
                        Text("username", // User's Display Name
                            style: TextStyle(
                                color: Color(0xff666666))), // Set colour
                        Text(
                          " 5h", //Time since sent
                          style:
                              TextStyle(color: Color(0xffbfbfbf)), // Set colour
                        )
                      ],
                    ),
                    const Text(
                      "dataaaaaaaaaaaaaaaaaaaaaaa",
                      textAlign: TextAlign.start,
                    ), // Create message content
                    // Create footer

                    Row(
                        mainAxisAlignment: MainAxisAlignment
                            .end, // Align row on right of screen
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    8), // Apply padding only to left and right
                            child: Text(
                              // Reply Placeholder
                              "Reply",
                              textAlign:
                                  TextAlign.end, // Align with right of screen
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    8), // Apply padding only to left and right
                            child: Text(
                              "Like", // Like Placeholder
                              textAlign:
                                  TextAlign.end, // Align with right of screen
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    8), // Apply padding only to left and right
                            child: Text(
                              "Dislike", // Dislike placeholder
                              textAlign:
                                  TextAlign.end, // Align with right of screen
                            ),
                          ),
                        ])
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
