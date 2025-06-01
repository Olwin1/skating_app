import "dart:math" as math;

import "package:flutter/material.dart";
import "package:in_app_notification/in_app_notification.dart";
import "package:patinka/misc/notifications/animated_line.dart";
import "package:patinka/swatch.dart";

/// Duration (in seconds) for how long the notification should remain visible.
const int dur = 1;

/// Handles a tap event on the notification.
///
/// Currently an empty placeholder, implement logic as required.
///
/// @param context The BuildContext in which this tap occurred.
/// @param errorMessage The error message shown in the notification.
void handleTap(final BuildContext context, final String errorMessage) async {
  // Placeholder for handling tap events on the notification.
}

/// Displays an in-app notification with the given error message.
///
/// @param context The BuildContext to display the notification in.
/// @param errorMessage The message to be shown in the notification.
void showNotification(final BuildContext context, final String errorMessage) {
  InAppNotification.show(
    onTap: () => handleTap(context, errorMessage), // Attach tap handler.
    child: NotificationBody(
        minHeight: 26, content: errorMessage, duration: dur), // Custom body.
    context: context,
    duration: const Duration(seconds: dur), // Duration to show the message.
  );
}

/// A widget representing the body of the notification, with styling and animation.
///
/// Displays an error label, the message, and a simple animated line.
///
/// @param content The main message content to display.
/// @param duration How long (in seconds) the notification will be visible.
/// @param minHeight The minimum height constraint for the notification.
class NotificationBody extends StatelessWidget {
  const NotificationBody({
    required this.content,
    required this.duration,
    super.key,
    this.minHeight = 0.0,
  });

  /// Minimum height for the notification container.
  final double minHeight;

  /// The actual message content to be shown in the notification.
  final String content;

  /// Duration (in seconds) for which the notification is displayed.
  final int duration;

  @override
  Widget build(final BuildContext context) {
    // Ensure the min height does not exceed the screen height.
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
          color: const Color(0xff440000), // Dark red background.
          borderRadius: BorderRadius.circular(16), // Rounded corners.
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Static label indicating this is an error.
                  Text(
                    "Error",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: swatch[101], // Use defined colour swatch.
                    ),
                  ),
                  // The actual error content text, with wrapping.
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
            const SizedBox(height: 5), // Spacer before the animation.
            AnimatedLine(duration: duration), // Bottom animated line.
          ],
        ),
      ),
    );
  }
}
