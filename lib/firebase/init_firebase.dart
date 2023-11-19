import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:patinka/firebase_options.dart';
import 'package:patinka/local_notification.dart';

Future<void> initialiseFirebase() async {
  if (Platform.isWindows || Platform.isLinux) {
    return;
  }
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) => NotificationManager.instance.initialize());
}
