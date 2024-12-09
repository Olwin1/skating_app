import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:patinka/social_media/report_content_type.dart';
import 'package:patinka/social_media/user_reports/buttons.dart';

class MessageOptionsBottomSheet extends StatelessWidget {
  final Message message; // Replace with actual comment model type

  const MessageOptionsBottomSheet({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ReportButton(
            reportContentType: ReportContentType.message,
            contentId: message.id,
            reportedUserId: message.author.id),
        BlockButton(blockUserId: message.author.id)
      ],
    );
  }
}
