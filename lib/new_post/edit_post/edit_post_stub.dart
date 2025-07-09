import "dart:typed_data";

import "package:flutter/material.dart";
import "package:patinka/l10n/app_localizations.dart";


class EditPost extends StatelessWidget {
  const EditPost({
    required this.callback,
    required this.selectedImage,
    super.key,
  });

  final Function callback;
  final Uint8List? selectedImage;

  @override
  Widget build(final BuildContext context) =>
      Center(child: Text(AppLocalizations.of(context)!.platformNotSupported));
}
