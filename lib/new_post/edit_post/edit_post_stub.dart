import "package:flutter/material.dart";

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
      const Center(child: Text("Platform not supported."));
}
