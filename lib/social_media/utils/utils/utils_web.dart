import "package:flutter/material.dart";
import "package:flutter/services.dart"; // for rootBundle or similar
import "package:patinka/common_logger.dart";
import "package:patinka/social_media/utils/utils/base_utils.dart";

class Utils extends BaseUtils {
  static void getImage(
      final String filePath, final Function(ImageProvider) callback) async {
    try {
      // Load as asset or from a URL if needed
      final ByteData bytes = await rootBundle.load(filePath);
      final Uint8List uint8List = bytes.buffer.asUint8List();
      final MemoryImage memoryImage = MemoryImage(uint8List);
      callback(memoryImage);
    } catch (e) {
      commonLogger.e("Failed to load image on web: $e");
      callback(const AssetImage("assets/placeholder.png")); // fallback
    }
  }

  static void loadImage(
      final Function getImage, final MediaQueryData mediaQuery) {
    BaseUtils.loadImage(getImage, mediaQuery);
  }
}
