import 'package:flutter/material.dart';
import 'package:patinka/social_media/report_content_type.dart';
import 'utils.dart';

class ReportReasonBottomSheet extends StatelessWidget {
  const ReportReasonBottomSheet({super.key, required this.reportContentType});
  final ReportContentType reportContentType;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Please Select a Reason For Your Report:",
          style: TextStyle(fontSize: 15),
        ),
        ReportReasonButton(reason: "Spam or Scam", reportContentType: reportContentType),
        ReportReasonButton(reason: "Inappropriate Content", reportContentType: reportContentType),
        ReportReasonButton(reason: "False information", reportContentType: reportContentType),
        ReportReasonButton(reason: "Harassment or Bullying", reportContentType: reportContentType),
        ReportReasonButton(reason: "Impersonation", reportContentType: reportContentType),
        ReportReasonButton(reason: "Threats", reportContentType: reportContentType),
        ReportReasonButton(reason: "I'm not sure", reportContentType: reportContentType),
      ],
    );
  }
}

class ReportReasonButton extends StatelessWidget {
  final String reason;

  const ReportReasonButton({super.key, required this.reason, required this.reportContentType});
  final ReportContentType reportContentType;

  static bool handleReportCreation(String reason, ReportContentType reportContentType) {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ButtonBuilders.createTextReportButton(reason, () {
      handleReportCreation(reason, reportContentType);
      Navigator.pop(context); // Close the reason sheet after selecting
    });
  }
}
