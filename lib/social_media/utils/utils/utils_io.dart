import "dart:io";
import "package:flutter/material.dart";
import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/social_media/utils/utils/base_utils.dart";

class Utils extends BaseUtils {
  static void getImage(
      final String filePath, final Function(ImageProvider) callback) {
    getApplicationDocumentsDirectory()
        .then((final applicationDocumentsDirectory) {
      final File file = File(path
          .join(applicationDocumentsDirectory.path, path.basename(filePath))
          .replaceAll('"', ""));
      commonLogger.d("File exists: ${file.existsSync()}");
      final FileImage fileImage = FileImage(file);
      callback(fileImage);
    });
  }

  static void loadImage(
      final Function getImage, final MediaQueryData mediaQuery) {
    BaseUtils.loadImage(getImage, mediaQuery);
  }
}
