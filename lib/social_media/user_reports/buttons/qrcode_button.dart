import "package:flutter/material.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/social_media/user_reports/utils.dart";
import "package:patinka/swatch.dart";

class QRCodeButton extends StatelessWidget {
  const QRCodeButton({super.key});

  @override
  Widget build(final BuildContext context) => ButtonBuilders.createTextButton(
        Icons.qr_code,
        "Create QR Code",
        swatch[601]!,
        () {
          commonLogger.i(
              "QR Code Functionality Placeholder"); // Placeholder for QR code functionality
        },
      );
}
