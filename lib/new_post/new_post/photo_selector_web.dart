import "dart:typed_data";

import "package:flutter/material.dart";
import "package:image_picker_web/image_picker_web.dart";
import "package:patinka/new_post/edit_post/edit_post.dart";

/// A web-only widget for selecting an image from the user's device.
///
/// Displays a button that opens the browser's file picker.
/// After the user selects an image, this widget transitions
/// to displaying an [EditPost] screen with the chosen image.
class PlatformPhotoSelector extends StatefulWidget {
  /// Creates a [PlatformPhotoSelector].
  const PlatformPhotoSelector({required this.onImageSelected, super.key});
  final Function onImageSelected;

  @override
  State<PlatformPhotoSelector> createState() => _PlatformPhotoSelectorState();
}

class _PlatformPhotoSelectorState extends State<PlatformPhotoSelector> {
  /// The bytes of the image selected by the user.
  Uint8List? selectedImage;

  /// Stores the image in state and triggers a rebuild.
  void imageSelector(final Uint8List image) {
    setState(() {
      selectedImage = image;
    });
  }

  /// Opens the web file picker to let the user choose an image.
  ///
  /// If the user picks an image, it loads the bytes into [selectedImage]
  /// and transitions to the edit screen.
  Future<void> _pickImage(final BuildContext context) async {
    // Use image_picker_web to prompt the browser's file picker.
    final Uint8List? bytesFromPicker = await ImagePickerWeb.getImageAsBytes();

    if (bytesFromPicker != null) {
      imageSelector(bytesFromPicker);
    }
  }

  @override
  Widget build(final BuildContext context) {
    if (selectedImage == null) {
      // If no image is selected yet, show the button for picking an image.
      return SizedBox(
        height: MediaQuery.sizeOf(context).height,
        child: Center(
          child: ElevatedButton.icon(
            onPressed: () => _pickImage(context),
            icon: const Icon(Icons.image),
            label: const Text("Select Image"),
          ),
        ),
      );
    } else {
      // Once an image is selected, show the EditPost screen.
      final image = selectedImage!;
      return SizedBox(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        child: EditPost(selectedImage: image),
      );
    }
  }
}
