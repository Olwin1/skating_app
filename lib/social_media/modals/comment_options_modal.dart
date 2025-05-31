import "package:flutter/material.dart";
import "package:patinka/social_media/report_content_type.dart";
import "package:patinka/social_media/user_reports/buttons/block_button.dart";
import "package:patinka/social_media/user_reports/buttons/report_button.dart";

class CommentOptionsBottomSheet extends StatelessWidget { // Replace with actual comment model type

  const CommentOptionsBottomSheet({
    required this.comment, super.key,
  });
  final dynamic comment;

  @override
  Widget build(final BuildContext context) => Padding(
    // Add padding so it forces focus on the window by making it wider
    padding: const EdgeInsets.symmetric(horizontal: 48), 
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ReportButton(reportContentType: ReportContentType.comment, contentId: comment["comment_id"], userId: comment["sender_id"], isBlocked: false,),
        BlockButton(userId: comment["sender_id"])
      ],
    ));
}
