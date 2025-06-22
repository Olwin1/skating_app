import "dart:io";

import "package:flutter/material.dart";
import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart";
import "package:patinka/api/config/config.dart";
import "package:patinka/api/image/image.dart";
import "package:patinka/caching/manager.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/services/navigation_service.dart";

class BaseUtils {
  static void getImage(
      final String filePath, final Function(ImageProvider) callback) {}

  static void loadImage(
      final Function getImage, final MediaQueryData mediaQuery) {
    // getImage callback to set state in main class and then in turn call getImage in Utils
    NetworkManager.instance
        .getLocalData(name: "current-background", type: CacheTypes.background)
        .then((final filePath) {
      if (filePath != null) {
        getImage(filePath);
      } else {
        if (NavigationService.currentNavigatorKey.currentContext!.mounted) {
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
