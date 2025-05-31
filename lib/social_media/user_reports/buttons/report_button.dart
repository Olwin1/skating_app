import "package:flutter/material.dart";
import "package:patinka/api/auth.dart";
import "package:patinka/social_media/report_content_type.dart";
import "package:patinka/social_media/user_reports/buttons/tri_button_state_toggle.dart";

class ReportButton extends TriButtonStateToggle<ReportButton> {
  const ReportButton(
      {required super.userId,
      required this.reportContentType,
      required this.contentId,
      required this.isBlocked,
      super.key});

  final ReportContentType reportContentType;
  final String contentId;
  final bool isBlocked;

  @override
  TriButtonStateToggleState<ReportButton> createState() => _ReportButtonState();
}

class _ReportButtonState extends TriButtonStateToggleState<ReportButton> {
  @override
  Future<void> initButtonState() async {
    final String userId = await AuthenticationAPI.getUserId();
      if (userId == widget.userId) {
        setState(() => buttonState = ToggleButtonState.secondary);
      } else {
        setState(() => buttonState = ToggleButtonState.primary);
      }
  }

  @override
  Future<void> onPrimaryPressed() async {
    // Report!!!!
    
    //await SupportAPI.postReportMessage(widget.contentId);
  }

  @override
  Future<void> onSecondaryPressed() async {
    // Delete whatever it is
    //await SupportAPI.del(widget.contentId);
  }

  @override
  IconData get primaryIcon => Icons.block;
  @override
  IconData get secondaryIcon => Icons.block;

  @override
  String get primaryLabel {
    switch (widget.reportContentType) {
      case ReportContentType.post:
        return "Report Post";
      case ReportContentType.message:
        return "Report Message";
      case ReportContentType.comment:
        return "Report Comment";
    }
  }

  @override
  String get secondaryLabel {
    switch (widget.reportContentType) {
      case ReportContentType.post:
        return "Delete Post";
      case ReportContentType.message:
        return "Delete Message";
      case ReportContentType.comment:
        return "Delete Comment";
    }
  }

  @override
  Color get primaryColor => Colors.red.shade700;
  @override
  Color get secondaryColor => Colors.grey.shade400;
}
