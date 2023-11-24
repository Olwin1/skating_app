// Import necessary Dart and Flutter packages
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

// Function to initialize the window manager
Future<void> initialiseWindowManager() async {
  // Check if the platform is Linux, Windows, or MacOS
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    // Ensure that the window manager is initialized
    await windowManager.ensureInitialized();

    // Define window options for the application
    WindowOptions windowOptions = const WindowOptions(
      size: Size(560, 1000), // Initial window size
      maximumSize: Size(560, 1000), // Maximum window size
      minimumSize: Size(380, 680), // Minimum window size
      center: false, // Do not center the window
      backgroundColor: Colors.transparent, // Transparent background
      skipTaskbar: false, // Do not skip the taskbar
      titleBarStyle: TitleBarStyle.normal, // Use a normal title bar style
    );

    // Wait until the window is ready to be shown, then show and focus it
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}
