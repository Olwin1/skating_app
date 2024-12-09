import 'package:flutter/material.dart';
import 'package:patinka/social_media/report_content_type.dart';
import 'package:patinka/social_media/user_reports/buttons.dart';

class PostOptionsBottomSheet extends StatelessWidget {
  final dynamic post; // Replace with your actual post model type
  final bool savedState;
  final Function(bool) setSavedState;

  const PostOptionsBottomSheet({
    super.key,
    required this.post,
    required this.savedState,
    required this.setSavedState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SaveButton(
            post: post, savedState: savedState, setSavedState: setSavedState),
        QRCodeButton(),
        ReportButton(reportContentType: ReportContentType.post,),
      ],
    );
  }
}
