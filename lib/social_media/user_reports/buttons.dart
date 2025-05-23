import "package:flutter/material.dart";
import "package:patinka/api/support.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/misc/navbar_provider.dart";
import "package:patinka/social_media/handle_buttons.dart";
import "package:patinka/social_media/report_content_type.dart";
import "package:patinka/social_media/user_reports/report_reason.dart";
import "package:patinka/social_media/user_reports/report_user.dart";
import "package:patinka/social_media/user_reports/utils.dart";
import "package:patinka/swatch.dart";
import "package:provider/provider.dart";

class SaveButton extends StatelessWidget {
  const SaveButton({
    required this.post,
    required this.savedState,
    required this.setSavedState,
    super.key,
  });
  final dynamic post; // Replace with your actual post model type
  final bool savedState;
  final Function(bool) setSavedState;

  @override
  Widget build(final BuildContext context) => ButtonBuilders.createTextButton(
        Icons.save,
        "Save Post",
        swatch[601]!,
        () async {
          await handleSavePressed(savedState, setSavedState, post);
          if (!context.mounted) {
            return;
          }
          Navigator.pop(context);
        },
      );
}

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

class ReportButton extends StatelessWidget {
  const ReportButton(
      {required this.reportContentType,
      required this.contentId,
      required this.reportedUserId,
      required this.isBlocked,
      super.key});
  final ReportContentType reportContentType;
  final String contentId;
  final String reportedUserId;
  final bool isBlocked;

  @override
  Widget build(final BuildContext context) {
    String reportText;
    switch (reportContentType) {
      case ReportContentType.post:
        reportText = "Report Post";
      case ReportContentType.message:
        reportText = "Report Message";
      case ReportContentType.comment:
        reportText = "Report Comment";
    }

    return ButtonBuilders.createTextButton(
      Icons.report,
      reportText,
      Colors.red.shade700,
      () {
        Navigator.pop(context);
        WidgetsBinding.instance.addPostFrameCallback((final _) {
          Provider.of<BottomBarVisibilityProvider>(context, listen: false)
              .hide();
        });
        ModalBottomSheet.show(
            context: context,
            builder: (final context) => ReportReasonBottomSheet(
                  reportContentType: reportContentType,
                  contentId: contentId,
                  reportedUserId: reportedUserId,
                  isBlocked: isBlocked,
                ),
            startSize: 0.65);
      },
    );
  }
}

class BlockButton extends StatelessWidget {
  const BlockButton({required this.blockUserId, super.key});
  final String blockUserId;
  //TODO: Check if is blocked
  @override
  Widget build(final BuildContext context) => ButtonBuilders.createTextButton(
        Icons.block,
        "Block User",
        Colors.red.shade700,
        () async {
          Navigator.pop(context);
          WidgetsBinding.instance.addPostFrameCallback((final _) {
            Provider.of<BottomBarVisibilityProvider>(context, listen: false)
                .hide();
          });
          SupportAPI.postBlockUser(blockUserId);
          // ModalBottomSheet.show(
          //     context: context,
          //     builder: (context) => BlockedBottomSheet(reportContentType: reportContentType),
          //     startSize: 0.65);
        },
      );
}
