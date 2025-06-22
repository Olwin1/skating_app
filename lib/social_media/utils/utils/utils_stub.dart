import "package:flutter/material.dart";
import "package:patinka/social_media/utils/utils/base_utils.dart";

class Utils extends BaseUtils {
  static void getImage(
      final String filePath, final Function(ImageProvider) callback) {
    callback(const AssetImage("assets/unsupported_platform.png"));
  }

  static void loadImage(
      final Function getImage, final MediaQueryData mediaQuery) {
    BaseUtils.loadImage(getImage, mediaQuery);
  }
}
