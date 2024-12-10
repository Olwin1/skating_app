import "package:flutter/material.dart";
import "package:patinka/api/reports.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/social_media/report_content_type.dart";
import "package:patinka/social_media/user_reports/report_user.dart";
import "package:patinka/social_media/user_reports/utils.dart";

class ReportReasonBottomSheet extends StatelessWidget {
  const ReportReasonBottomSheet(
      {required this.reportContentType, required this.contentId, required this.reportedUserId, super.key});
  final ReportContentType reportContentType;
  final String contentId;
  final String reportedUserId;

  @override
  Widget build(final BuildContext context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Please Select a Reason For Your Report:",
          style: TextStyle(fontSize: 15),
        ),
        ReportReasonButton(
            reason: "Spam or Scam",
            reportContentType: reportContentType,
            contentId: contentId,
            reportedUserId: reportedUserId),
        ReportReasonButton(
            reason: "Inappropriate Content",
            reportContentType: reportContentType,
            contentId: contentId,
            reportedUserId: reportedUserId),
        ReportReasonButton(
            reason: "False information",
            reportContentType: reportContentType,
            contentId: contentId,
            reportedUserId: reportedUserId),
        ReportReasonButton(
            reason: "Harassment or Bullying",
            reportContentType: reportContentType,
            contentId: contentId,
            reportedUserId: reportedUserId),
        ReportReasonButton(
            reason: "Impersonation",
            reportContentType: reportContentType,
            contentId: contentId,
            reportedUserId: reportedUserId),
        ReportReasonButton(
            reason: "Threats",
            reportContentType: reportContentType,
            contentId: contentId,
            reportedUserId: reportedUserId),
        ReportReasonButton(
            reason: "I'm not sure",
            reportContentType: reportContentType,
            contentId: contentId,
            reportedUserId: reportedUserId),
      ],
    );
}

class ReportReasonButton extends StatelessWidget {

  const ReportReasonButton(
      {required this.reason, required this.reportContentType, required this.contentId, required this.reportedUserId, super.key});
  final String reason;
  final ReportContentType reportContentType;
  final String contentId;
  final String reportedUserId;

  static Future<bool> handleReportCreation(
      final String reason,
      final ReportContentType reportContentType,
      final String contentId,
      final String reportedUserId) async {
    try {
      await ReportAPI.postReport(
          reportContentType, contentId, reportedUserId, reason);
      return true;
    } catch (e) {
      commonLogger.w(e);
      return false;
    }
  }

  @override
  Widget build(final BuildContext context) => ButtonBuilders.createTextReportButton(reason, () async {
      Navigator.pop(context); // Close the reason sheet after selecting
      final bool result = await handleReportCreation(
          reason, reportContentType, contentId, reportedUserId);
      if (!context.mounted) {
        return;
      }
      ModalBottomSheet.show(
        context: context,
        builder: (final context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(result ? "Report Successfully Filed" : "Error Filing Report"),
            Text(result
                ? "All reports are dealt with manually so may take some time to process.  "
                : "We're not sure what went wrong.  Please Try Submitting again or contacting support.  ")
          ],
        ),
        startSize: 0.3,
      );
    });
}
