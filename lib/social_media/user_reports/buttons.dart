import 'package:flutter/material.dart';
import 'package:patinka/misc/navbar_provider.dart';
import 'package:patinka/social_media/handle_buttons.dart';
import 'package:patinka/social_media/report_content_type.dart';
import 'package:patinka/social_media/user_reports/report_reason.dart';
import 'package:patinka/social_media/user_reports/utils.dart';
import 'package:patinka/swatch.dart';
import 'package:provider/provider.dart';

import 'report_user.dart';

class SaveButton extends StatelessWidget {
  final dynamic post; // Replace with your actual post model type
  final bool savedState;
  final Function(bool) setSavedState;

  const SaveButton({
    super.key,
    required this.post,
    required this.savedState,
    required this.setSavedState,
  });

  @override
  Widget build(BuildContext context) {
    return ButtonBuilders.createTextButton(
      Icons.save,
      "Save Post",
      swatch[601]!,
      () async {
        await handleSavePressed(savedState, setSavedState, post);
        if (!context.mounted) return;
        Navigator.pop(context);
      },
    );
  }
}

class QRCodeButton extends StatelessWidget {
  const QRCodeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ButtonBuilders.createTextButton(
      Icons.qr_code,
      "Create QR Code",
      swatch[601]!,
      () {
        print("AAA"); // Placeholder for QR code functionality
      },
    );
  }
}

class ReportButton extends StatelessWidget {
  const ReportButton({super.key, required this.reportContentType});
  final ReportContentType reportContentType;

  @override
  Widget build(BuildContext context) {
    String reportText;
    switch(reportContentType) {
      case ReportContentType.post:
        reportText = "Report Post";
        break;
      case ReportContentType.message:
        reportText = "Report Message";
        break;
      case ReportContentType.comment:
        reportText = "Report Comment";

    }

    return ButtonBuilders.createTextButton(
      Icons.report,
      reportText,
      Colors.red.shade700,
      () {
        Navigator.pop(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<BottomBarVisibilityProvider>(context, listen: false)
              .hide();
        });
        ModalBottomSheet.show(
            context: context,
            builder: (context) => ReportReasonBottomSheet(reportContentType: reportContentType),
            startSize: 0.65);
      },
    );
  }
}

class BlockButton extends StatelessWidget {
  const BlockButton({super.key, required this.blockUserId});
  final String blockUserId;

  @override
  Widget build(BuildContext context) {
    return ButtonBuilders.createTextButton(
      Icons.block,
      "Block User",
      Colors.red.shade700,
      () {
        Navigator.pop(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<BottomBarVisibilityProvider>(context, listen: false)
              .hide();
        });
        // ModalBottomSheet.show(
        //     context: context,
        //     builder: (context) => BlockedBottomSheet(reportContentType: reportContentType),
        //     startSize: 0.65);
      },
    );
  }
}
