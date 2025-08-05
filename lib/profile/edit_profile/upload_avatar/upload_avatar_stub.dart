import "package:flutter/material.dart";
import "package:patinka/misc/notifications/error_notification.dart"
    as error_notification;

/// A stub widget for selecting an image from the user's device.
///
/// Simply shows an error for unsupported platform
class ChangeAvatarPage extends StatefulWidget {
  const ChangeAvatarPage({super.key});

  @override
  State<ChangeAvatarPage> createState() => _ChangeAvatarPage();
}

class _ChangeAvatarPage extends State<ChangeAvatarPage> {
  @override
  void initState() {
    error_notification.showNotification(context, "Error: Unsupported Platform");
    super.initState();
  }

  @override
  Widget build(final BuildContext context) => const SizedBox.shrink();
}
