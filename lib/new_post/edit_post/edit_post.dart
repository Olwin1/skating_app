import "dart:typed_data"; // Import for handling raw byte data (e.g. images).

import "package:flutter/material.dart"; // Flutter UI components.
import "package:flutter/services.dart"; // Flutter platform-specific services.
import "package:patinka/new_post/send_post.dart"; // Custom page for sending a post.
import "package:pro_image_editor/features/crop_rotate_editor/utils/crop_aspect_ratios.dart"; // Aspect ratio constants.
import "package:pro_image_editor/pro_image_editor.dart"; // Image editing package.

/*
 * EditPost widget allows the user to edit a selected image
 * using ProImageEditor and then proceed to post it.
 */
/// A screen that allows editing an image via ProImageEditor
/// before sending it as a new post.
class EditPost extends StatefulWidget {
  /// Creates an [EditPost] widget.
  ///
  /// The [selectedImage] parameter must not be null and contains
  /// the raw image data as bytes.
  const EditPost({
    required this.selectedImage,
    super.key,
  });

  /// The image to be edited, provided as raw bytes.
  final Uint8List selectedImage;

  @override
  State<EditPost> createState() => _EditPost();
}

/// State class for [EditPost].
class _EditPost extends State<EditPost> {
  /// Optional image provider for handling image rendering.
  ImageProvider? provider;

  /// GlobalKey to access the internal state of [ProImageEditor].
  final editorKey = GlobalKey<ProImageEditorState>();

  @override
  void initState() {
    super.initState();

    // Run this after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      // Automatically open the crop/rotate editor when the page loads.
      editorKey.currentState?.openCropRotateEditor();
    });
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        body: SizedBox(
          child: ProImageEditor.memory(
            key: editorKey,
            widget.selectedImage,
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (final Uint8List bytes) async {
                // Navigate to SendPost screen once editing is complete.
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (final context, final animation,
                            final secondaryAnimation) =>
                        SendPost(
                      image: bytes,
                    ),
                    opaque: false,
                    transitionsBuilder: (final context, final animation,
                        final secondaryAnimation, final child) {
                      // Fade in the SendPost page.
                      final fadeAnimation =
                          Tween(begin: 0.0, end: 1.0).animate(animation);
                      return FadeTransition(
                        opacity: fadeAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
            configs: const ProImageEditorConfigs(
              cropRotateEditor: CropRotateEditorConfigs(
                initAspectRatio: CropAspectRatios.ratio1_1,
                aspectRatios: [AspectRatioItem(text: "Square", value: 1.0)],
              ),
            ),
          ),
        ),
      );
}
