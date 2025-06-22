import "package:firebase_core/firebase_core.dart";
import "package:flutter/foundation.dart" show kIsWeb;
import "package:patinka/firebase_options.dart";
import "package:patinka/local_notification.dart";

import "package:patinka/misc/supported_platforms/platform_stub.dart"
    if (dart.library.io) "package:patinka/misc/supported_platforms/platform_io.dart";

Future<void> initialiseFirebase() async {
  // If is web or an unsupported platform
  if (kIsWeb || isUnsupportedPlatform) {
    return;
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  NotificationManager.instance.initialize();
}
