import "package:flutter/material.dart";
import "package:patinka/swatch.dart";

class ListError extends StatelessWidget {
  // Constructor for FriendsTracker, which calls the constructor for its superclass (StatelessWidget)
  const ListError({required this.title, required this.body, super.key});
  final String body;

  final String title;

  // Override the build method of StatelessWidget to return a Consumer widget
  @override
  Widget build(final BuildContext context) => Center(
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
