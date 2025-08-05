import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_phoenix/flutter_phoenix.dart";
import "package:http/http.dart";
import "package:image_picker_web/image_picker_web.dart";
import "package:patinka/api/image/image.dart";
import "package:patinka/api/social.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/new_post/edit_post/edit_post.dart";
import "package:patinka/swatch.dart";
import "package:pro_image_editor/core/models/editor_callbacks/pro_image_editor_callbacks.dart";
import "package:pro_image_editor/core/models/editor_configs/pro_image_editor_configs.dart";
import "package:pro_image_editor/features/main_editor/main_editor.dart";

/// A web-only widget for selecting an image from the user's device.
///
/// Displays a button that opens the browser's file picker.
/// After the user selects an image, this widget transitions
/// to displaying an [EditPost] screen with the chosen image.
class ChangeAvatarPage extends StatefulWidget {
  const ChangeAvatarPage({super.key});

  @override
  State<ChangeAvatarPage> createState() => _ChangeAvatarPage();
}

class _ChangeAvatarPage extends State<ChangeAvatarPage> {
  /// The bytes of the image selected by the user.
  Uint8List? selectedImage;
  final GlobalKey _cropperKey =
      GlobalKey(debugLabel: "cropperKey"); // The key for the Cropper widget.

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

  void sendInfo(final Uint8List image) async {
    try {
      showDialog(
        useRootNavigator: false,
        context: context,
        barrierDismissible: false,
        builder: (final BuildContext context) => AlertDialog(
          backgroundColor: swatch[800],
          title: Text(
            "Processing",
            style: TextStyle(color: swatch[701]),
          ),
          content: Text(
            "Please wait...",
            style: TextStyle(color: swatch[901]),
          ),
        ),
      );
      // Call the "sendImage" function and wait for it to complete
      final String? imageId = await sendImage(image);
      // When "sendImage" completes successfully, call "postPost"
      // with the text from "descriptionController" and the returned value
      if (imageId != null) {
        await SocialAPI.setAvatar(imageId);
        // Wait for "postPost" to complete successfully
        // When "postPost" completes successfully, close the current screen
        if (mounted) {
          Phoenix.rebirth(context);
        }
      }
    } catch (e) {
      commonLogger.e("Error creating post: $e");
    }
  }

  Future<String?> sendImage(final Uint8List image) async {
    try {
      // Upload the image file
      final StreamedResponse? response = await uploadFile(image);
      final String? id = await response?.stream.bytesToString();
      if (id != null) {
        return id.substring(1, id.length - 1);
        //Navigator.of(context).pop();
      }
      // Close the current screen and go back to the previous screen
    } catch (e) {
      // If there is an error, print the error message to the console
      commonLogger.e("An Error Occurred: $e");
    }
    return null;
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
      return SizedBox(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: ProImageEditor.memory(
            selectedImage!,
            key: _cropperKey,
            configs: const ProImageEditorConfigs(
                cropRotateEditor: CropRotateEditorConfigs(
                  enabled: true,
                  initAspectRatio: 1.0,
                  aspectRatios: [
                    AspectRatioItem(text: "Square", value: 1.0),
                  ],
                  style: CropRotateEditorStyle(),
                ),
                // disable others:
                blurEditor: BlurEditorConfigs(enabled: false),
                filterEditor: FilterEditorConfigs(enabled: false),
                textEditor: TextEditorConfigs(enabled: false),
                emojiEditor: EmojiEditorConfigs(enabled: false),
                stickerEditor: StickerEditorConfigs(enabled: false),
                tuneEditor: TuneEditorConfigs(enabled: false),
                paintEditor: PaintEditorConfigs(enabled: false)),
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (final croppedBytes) async {
                // Send image to server
                sendInfo(croppedBytes);
              },
            ),
          )
          );
    }
  }
}
