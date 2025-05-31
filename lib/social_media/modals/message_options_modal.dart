import "package:flutter/material.dart";
import "package:flutter_chat_types/flutter_chat_types.dart";
import "package:patinka/social_media/report_content_type.dart";
import "package:patinka/social_media/user_reports/buttons/block_button.dart";
import "package:patinka/social_media/user_reports/buttons/report_button.dart";

class MessageOptionsBottomSheet extends StatelessWidget { // Replace with actual comment model type

  const MessageOptionsBottomSheet({
    required this.message, super.key,
  });
  final Message message;

  @override
  Widget build(final BuildContext context) => Padding(
    // Add some padding to make it fit the screen better
    padding:const EdgeInsets.symmetric(horizontal: 48), 
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ReportButton(
            reportContentType: ReportContentType.message,
            contentId: message.id,
            userId: message.author.id,
            //TODO: Add check for is blocked
            isBlocked: false),

        BlockButton(userId: message.author.id)
      ],
    ));
}
