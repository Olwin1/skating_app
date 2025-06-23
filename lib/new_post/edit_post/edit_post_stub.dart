import "package:flutter/material.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class EditPost extends StatelessWidget {
  const EditPost({
    required this.callback,
    required this.selected,
    required this.selectedImage,
    super.key,
  });

  final Function callback;
  final bool selected;
  final String selectedImage;

  @override
  Widget build(final BuildContext context) =>
      Center(child: Text(AppLocalizations.of(context)!.platformNotSupported));
}
