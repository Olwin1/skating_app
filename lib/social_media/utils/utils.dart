import "dart:io";

import "package:flutter/material.dart";
import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart";
import "package:patinka/api/config.dart";
import "package:patinka/api/image.dart";
import "package:patinka/caching/manager.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/services/navigation_service.dart";

class Utils {
  static void getImage(final String filePath, final Function callback) {
    getApplicationDocumentsDirectory()
        .then((final applicationDocumentsDirectory) {
      final File file = File(path
          .join(applicationDocumentsDirectory.path, path.basename(filePath))
          .replaceAll('"',
              "")); // Replace all " because it breaks it for some weird reason
      commonLogger.d(file.existsSync());
      final FileImage fileImage = FileImage(file);
      callback(fileImage);
    });
  }

  static void loadImage(final Function getImage) {
    // getImage callback to set state in main class and then in turn call getImage in Utils
    NetworkManager.instance
        .getLocalData(name: "current-background", type: CacheTypes.background)
        .then((final filePath) {
      if (filePath != null) {
        getImage(filePath);
      } else {
        if (NavigationService.currentNavigatorKey.currentContext!.mounted) {
          final MediaQueryData mediaQuery = MediaQuery.of(
              NavigationService.currentNavigatorKey.currentContext!);
          final physicalPixelWidth =
              mediaQuery.size.width * mediaQuery.devicePixelRatio;
          final physicalPixelHeight =
              mediaQuery.size.height * mediaQuery.devicePixelRatio;
          downloadBackgroundImage(physicalPixelWidth, physicalPixelHeight)
              .then((final value) {
            if (value) {
              commonLogger.d("Downloading Value is true");
              NetworkManager.instance
                  .getLocalData(
                      name: "current-background", type: CacheTypes.background)
                  .then((final filePath) {
                if (filePath != null) {
                  commonLogger.d("File path aint none");
                  getImage(filePath);
                }
              });
            }
          });
        }
      }
    });
  }
}
