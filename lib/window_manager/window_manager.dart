import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

Future<void> initialiseWindowManager() async {
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(560, 1000),
      maximumSize: Size(560, 1000),
      minimumSize: Size(380, 680),
      center: false,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}
