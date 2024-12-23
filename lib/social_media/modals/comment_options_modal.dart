import "package:flutter/material.dart";
import "package:patinka/social_media/report_content_type.dart";
import "package:patinka/social_media/user_reports/buttons.dart";

class CommentOptionsBottomSheet extends StatelessWidget { // Replace with actual comment model type

  const CommentOptionsBottomSheet({
    required this.comment, super.key,
  });
  final dynamic comment;

  @override
  Widget build(final BuildContext context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ReportButton(reportContentType: ReportContentType.comment, contentId: comment["comment_id"], reportedUserId: comment["sender_id"], isBlocked: false,),
        BlockButton(blockUserId: comment["sender_id"])
      ],
    );
}
