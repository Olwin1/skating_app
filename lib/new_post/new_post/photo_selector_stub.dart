import "dart:typed_data";

import "package:flutter/material.dart";

class PlatformPhotoSelector extends StatelessWidget {
  const PlatformPhotoSelector({
    super.key,
    this.onImageSelected,
    this.update,
  });

  final void Function(Uint8List image)? onImageSelected;
  final ValueChanged<String>? update;

  @override
  Widget build(final BuildContext context) => const Center(
        child: Text("PlatformPhotoSelector not implemented."),
      );
}
