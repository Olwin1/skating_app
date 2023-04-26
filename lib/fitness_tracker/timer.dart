import 'package:flutter/material.dart';
import 'package:timer_builder/timer_builder.dart';

// This is a stateless widget that displays a clock timer based on a starting time.
class ClockWidget extends StatelessWidget {
  // The constructor takes a key and a required starting time parameter.
  const ClockWidget({super.key, required this.startTime});
  final DateTime startTime;

  @override
  Widget build(BuildContext context) {
    // The TimerBuilder is used to rebuild the widget every second.
    return TimerBuilder.periodic(const Duration(seconds: 1),
        builder: (context) {
      // Calculate the difference between the current time and the starting time.
      var diff = DateTime.now().difference(startTime);
      String time;
      // If the difference is less than 60 minutes, display the time in minutes and seconds.
      if (diff.inMinutes < 60) {
        time =
            '${diff.inMinutes}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}';
      } else {
        // If the difference is more than 60 minutes, display the time in hours, minutes, and seconds.
        time =
            '${diff.inHours}:${(diff.inMinutes % 60).toString().padLeft(2, "0")}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}';
      }
      // Return a Text widget displaying the calculated time.
      return Text(time);
    });
  }
}
