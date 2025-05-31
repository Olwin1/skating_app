import "package:flutter/material.dart";
import "package:patinka/social_media/report_content_type.dart";
import "package:patinka/social_media/user_reports/buttons/qrcode_button.dart";
import "package:patinka/social_media/user_reports/buttons/report_button.dart";
import "package:patinka/social_media/user_reports/buttons/save_button.dart";

class PostOptionsBottomSheet extends StatelessWidget {

  const PostOptionsBottomSheet({
    required this.post, required this.savedState, required this.setSavedState, super.key,
  });
  final dynamic post; // Replace with your actual post model type
  final bool savedState;
  final Function(bool) setSavedState;

  @override
  Widget build(final BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SaveButton(
            post: post, savedState: savedState, setSavedState: setSavedState),
        const QRCodeButton(),
        ReportButton(
            reportContentType: ReportContentType.post,
            contentId: post["post_id"],
            userId: post["author_id"],
            isBlocked: false,
            ),
      ],
    );
}
