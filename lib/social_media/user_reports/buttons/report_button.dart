import "package:flutter/material.dart";
import "package:patinka/misc/navbar_provider.dart";
import "package:patinka/social_media/report_content_type.dart";
import "package:patinka/social_media/user_reports/report_reason.dart";
import "package:patinka/social_media/user_reports/report_user.dart";
import "package:patinka/social_media/user_reports/utils.dart";
import "package:provider/provider.dart";

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
