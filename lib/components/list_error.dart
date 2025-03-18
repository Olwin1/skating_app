import "package:flutter/material.dart";
import "package:patinka/social_media/utils/pair.dart";
import "package:patinka/swatch.dart";

class ListError extends StatelessWidget {
  // Constructor for FriendsTracker, which calls the constructor for its superclass (StatelessWidget)
  const ListError({required this.message, super.key});
  final Pair<String> message;

  // Override the build method of StatelessWidget to return a Consumer widget
  @override
  Widget build(final BuildContext context) => Center(
          child: Column(children: [
        const SizedBox(
          height: 150,
        ),
        Text(
          message.header,
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: swatch[701]),
        ),
        Text(message.body, style: TextStyle(fontSize: 20, color: swatch[601])),
      ]));
}
