import 'package:flutter/material.dart';
import '../swatch.dart';

class ListError extends StatelessWidget {
  final String body;

  final String title;

  // Constructor for FriendsTracker, which calls the constructor for its superclass (StatelessWidget)
  const ListError({super.key, required this.title, required this.body});

  // Override the build method of StatelessWidget to return a Consumer widget
  @override
  Widget build(BuildContext context) {
    // Use the Consumer widget to listen for changes to the CurrentPage object
    return Center(
        child: Column(children: [
      const SizedBox(
        height: 150,
      ),
      Text(
        title,
        style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: swatch[701]),
      ),
      Text(body, style: TextStyle(fontSize: 20, color: swatch[601])),
    ]));
  }
}
