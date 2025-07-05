import "dart:typed_data";

import "package:flutter/material.dart";
//TODO Implement web version
class PlatformPhotoSelector extends StatelessWidget {
  const PlatformPhotoSelector({
    required this.onImageSelected, super.key,
  });

  final void Function(Uint8List image) onImageSelected;

  Future<void> _pickImage(final BuildContext context) async {
    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.image,
    //   withData: true,
    // );
    // if (result != null && result.files.single.bytes != null) {
    //   onImageSelected(result.files.single.bytes!);
    // }
  }

  @override
  Widget build(final BuildContext context) => ElevatedButton.icon(
      onPressed: () => _pickImage(context),
      icon: const Icon(Icons.image),
      label: const Text("Select Image"),
    );
}

