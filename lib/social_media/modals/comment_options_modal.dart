import 'package:flutter/material.dart';
import 'package:patinka/social_media/report_content_type.dart';
import 'package:patinka/social_media/user_reports/buttons.dart';

class CommentOptionsBottomSheet extends StatelessWidget {
  final dynamic comment; // Replace with actual comment model type

  const CommentOptionsBottomSheet({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ReportButton(reportContentType: ReportContentType.comment),
        BlockButton(blockUserId: comment["sender_id"])
      ],
    );
  }
}
