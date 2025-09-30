import "dart:math" as math;

import "package:flutter/material.dart";
import "package:in_app_notification/in_app_notification.dart";
import "package:patinka/misc/notifications/animated_line.dart";
import "package:patinka/swatch.dart";

/// Duration (in seconds) for how long notifications remain visible.
const int dur = 1;

/// Base widget for notifications, providing common layout/styling.
abstract class BaseNotificationBody extends StatelessWidget {
  const BaseNotificationBody({
    required this.content,
    required this.duration,
    required this.title,
    required this.backgroundColor,
    required this.titleColor,
    super.key,
    this.minHeight = 0.0,
  });

  final double minHeight;
  final String content;
  final int duration;

  /// Text label at the top ("Error", "Info", etc).
  final String title;

  /// Background color for the container.
  final Color backgroundColor;

  /// Title color (often from swatch).
  final Color titleColor;

  /// Base function for showing a notification.
  ///
  /// [context] - The build context to display the notification in.
  /// [message] - The message text.
  /// [child]   - The notification widget to display.
  static void showNotificationBase(final BuildContext context,
      final String message, final Widget child, final Function onTap) {
    InAppNotification.show(
      onTap: () => onTap(context, message),
      child: child,
      context: context,
      duration: const Duration(seconds: dur),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final minHeight = math.min(
      this.minHeight,
      MediaQuery.of(context).size.height,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Container(
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.only(left: 12, right: 12, top: 18),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  Text(
                    content,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15),
                  )
                ],
              ),
            ),
            const SizedBox(height: 5),
            AnimatedLine(duration: duration),
          ],
        ),
      ),
    );
  }
}
