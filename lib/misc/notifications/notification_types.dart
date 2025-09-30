import "package:flutter/material.dart";
import "package:patinka/misc/notifications/generic_notification.dart";
import "package:patinka/swatch.dart";

class PopupNotificationManager {
  /// Show an error notification.
  static void showErrorNotification(
      final BuildContext context, final String message) {
    BaseNotificationBody.showNotificationBase(context, message,
        ErrorNotificationBody(content: message, duration: dur), () => {});
  }

  /// Show an info notification.
  static void showInfoNotification(
      final BuildContext context, final String message) {
    BaseNotificationBody.showNotificationBase(context, message,
        InfoNotificationBody(content: message, duration: dur), () => {});
  }

  /// Show an info notification.
  static void showSuccessNotification(
      final BuildContext context, final String message) {
    BaseNotificationBody.showNotificationBase(context, message,
        SuccessNotificationBody(content: message, duration: dur), () => {});
  }
}

/// Error notification widget.
class ErrorNotificationBody extends BaseNotificationBody {
  ErrorNotificationBody({
    required super.content,
    required super.duration,
    super.minHeight,
    super.key,
  }) : super(
          title: "Error",
          backgroundColor: const Color(0xff440000), // Dark red
          titleColor: swatch[101]!, // Red-ish swatch
        );
}

/// Info notification widget.
class InfoNotificationBody extends BaseNotificationBody {
  const InfoNotificationBody({
    required super.content,
    required super.duration,
    super.minHeight,
    super.key,
  }) : super(
          title: "Info",
          backgroundColor: const Color(0xff003366), // Dark blue
          titleColor: Colors.white, // White title for contrast
        );
}

/// Success notification widget.
class SuccessNotificationBody extends BaseNotificationBody {
  const SuccessNotificationBody({
    required super.content,
    required super.duration,
    super.minHeight,
    super.key,
  }) : super(
          title: "Success",
          backgroundColor: const Color.fromARGB(255, 0, 102, 9), // Dark blue
          titleColor: Colors.white, // White title for contrast
        );
}
