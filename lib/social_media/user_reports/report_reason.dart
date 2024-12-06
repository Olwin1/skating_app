import 'package:flutter/material.dart';
import 'utils.dart';

class ReportReasonBottomSheet extends StatelessWidget {
  const ReportReasonBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Please Select a Reason For Your Report:",
          style: TextStyle(fontSize: 15),
        ),
        ReportReasonButton(reason: "Spam or Scam"),
        ReportReasonButton(reason: "Inappropriate Content"),
        ReportReasonButton(reason: "False information"),
        ReportReasonButton(reason: "Harassment or Bullying"),
        ReportReasonButton(reason: "Impersonation"),
        ReportReasonButton(reason: "Threats"),
        ReportReasonButton(reason: "I'm not sure"),
      ],
    );
  }
}

class ReportReasonButton extends StatelessWidget {
  final String reason;

  const ReportReasonButton({super.key, required this.reason});

  static bool handleReportCreation(String reason) {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ButtonBuilders.createTextReportButton(reason, () {
      handleReportCreation(reason);
      Navigator.pop(context); // Close the reason sheet after selecting
    });
  }
}
