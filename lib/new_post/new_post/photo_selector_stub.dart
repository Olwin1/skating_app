import "package:flutter/material.dart";

/// A widget that provides a platform-specific UI to select a photo
/// from the device (e.g. gallery, camera, etc.).
///
/// This is currently a stub and not yet implemented. It displays
/// only a placeholder text.
///
/// The widget reports the selected image (if any) via [onImageSelected].
/// Optionally, [update] can be used to notify other parts of the app
/// of additional changes.
class PlatformPhotoSelector extends StatelessWidget {
  /// Creates a [PlatformPhotoSelector].
  ///
  /// The [onImageSelected] callback is required and is triggered when
  /// the user selects an image. It should receive a value indicating
  /// the selected image path, URL, or identifier.
  ///
  /// The optional [update] callback can be used for notifying other
  /// logic or triggering external updates unrelated to image selection.
  const PlatformPhotoSelector({
    required this.onImageSelected,
    super.key,
    this.update,
  });

  /// A callback that can be used to notify external logic or
  /// trigger updates when certain events occur (e.g. state changes).
  final ValueChanged<String>? update;

  /// A function called when the user selects an image.
  ///
  /// The argument can be a local file path, an image URL,
  /// or any identifier depending on how this widget is implemented.
  final Function onImageSelected;

  @override
  Widget build(final BuildContext context) => const Center(
        child: Text("PlatformPhotoSelector not implemented."),
      );
}
