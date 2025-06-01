import "package:flutter/material.dart";
import "package:patinka/swatch.dart";

/// A widget that displays an animated horizontal line (progress bar)
/// that shrinks from full width to zero over a specified duration.
///
/// The animation lasts for `duration + 1` seconds to ensure there's
/// always a visual indication of the bar decreasing.
///
/// Example usage:
/// ```dart
/// AnimatedLine(duration: 5);
/// ```
class AnimatedLine extends StatefulWidget {
  /// Creates an [AnimatedLine] widget.
  ///
  /// The [duration] parameter specifies the length of the animation in seconds.
  const AnimatedLine({required this.duration, super.key});

  /// The duration (in seconds) for how long the line should animate.
  final int duration;

  @override
  AnimatedLineState createState() => AnimatedLineState();
}

class AnimatedLineState extends State<AnimatedLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialise the animation controller with a duration
    // that's 1 second longer than specified to always have the bar animating.
    _controller = AnimationController(
      duration: Duration(seconds: widget.duration + 1),
      vsync: this,
    );

    // Animate the width factor from 1.0 (full width) to 0.0 (empty)
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller)
      ..addListener(() {
        // Rebuild the widget on each animation tick
        setState(() {});
      });

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    // Dispose of the animation controller to free resources
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => SizedBox(
        // Set the full width of the widget
        width: double.maxFinite,
        // Height of the animated line
        height: 2,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            // Set the width factor based on the animation value
            widthFactor: _animation.value,
            child: Container(
              // Set the color of the line using your custom swatch
              color: swatch[601],
            ),
          ),
        ),
      );
}
