import "dart:typed_data";

import "package:flutter/material.dart";
import "package:image_picker_web/image_picker_web.dart";

/// A web-only widget for picking an image file from the user's device.
///
/// This widget displays a single button which opens the browser's
/// file picker dialog when pressed. Upon selecting an image,
/// the widget passes the image bytes to the [onImageSelected] callback.
///
/// Example usage:
///
/// ```dart
/// PlatformPhotoSelector(
///   onImageSelected: (Uint8List bytes) {
///     // Do something with the image bytes
///   },
/// )
/// ```
class PlatformPhotoSelector extends StatelessWidget {
  /// Creates a [PlatformPhotoSelector].
  ///
  /// The [onImageSelected] callback is required and will be called
  /// with the bytes of the selected image.
  const PlatformPhotoSelector({
    required this.onImageSelected,
    super.key,
  });

  /// Callback invoked when the user selects an image.
  ///
  /// The parameter [image] is a [Uint8List] containing the raw bytes
  /// of the selected image file.
  final void Function(Uint8List image) onImageSelected;

  /// Opens the web file picker to allow the user to select an image.
  ///
  /// If the user selects an image, its bytes are retrieved and
  /// passed to [onImageSelected]. Otherwise, nothing happens.
  Future<void> _pickImage(final BuildContext context) async {
    // Use the image_picker_web plugin to open the browser file picker.
    final Uint8List? bytesFromPicker = await ImagePickerWeb.getImageAsBytes();

    if (bytesFromPicker != null) {
      // If the user picked an image, notify the parent widget.
      onImageSelected(bytesFromPicker);
    }
  }

  @override
  Widget build(final BuildContext context) => Center(
        child: ElevatedButton.icon(
          // Trigger the image picker when the button is pressed.
          onPressed: () => _pickImage(context),
          icon: const Icon(Icons.image),
          label: const Text("Select Image"),
        ),
      );
}
