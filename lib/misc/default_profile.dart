import "package:flutter/material.dart";

import "package:patinka/swatch.dart";

class DefaultProfile extends StatelessWidget {
  const DefaultProfile({required this.radius, super.key});
  final double radius;

  @override
  Widget build(final BuildContext context) {
    // Build a paginated list view of comments using the PagedListView widget
    return CircleAvatar(
      // Create a circular avatar icon
      radius: radius, // Set radius to 36
      backgroundColor: swatch[900],
      child: SizedBox(
          width: 100,
          height: 100,
          child: ClipOval(
            child: Image.asset(
              "assets/icons/hand.png",
              fit: BoxFit.contain,
            ),
          )),
    );
  }
}
