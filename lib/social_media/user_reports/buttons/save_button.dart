import "package:flutter/material.dart";
import "package:patinka/social_media/handle_buttons.dart";
import "package:patinka/social_media/user_reports/utils.dart";
import "package:patinka/swatch.dart";

class SaveButton extends StatelessWidget {
  const SaveButton({
    required this.post,
    required this.savedState,
    required this.setSavedState,
    super.key,
  });
  final dynamic post; // Replace with your actual post model type
  final bool savedState;
  final Function(bool) setSavedState;

  @override
  Widget build(final BuildContext context) => ButtonBuilders.createTextButton(
        Icons.save,
        "Save Post",
        swatch[601]!,
        () async {
          await handleSavePressed(savedState, setSavedState, post);
          if (!context.mounted) {
            return;
          }
          Navigator.pop(context);
        },
      );
}
