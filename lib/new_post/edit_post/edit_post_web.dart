import "dart:typed_data";

import "package:cropperx/cropperx.dart";
import "package:flutter/material.dart";

class EditPost extends StatefulWidget {
  final Function callback;
  final bool selected;
  final String selectedImage; // You may not need this on web.

  const EditPost({
    required this.callback,
    required this.selected,
    required this.selectedImage,
    super.key,
  });

  @override
  State<EditPost> createState() => _EditPostWeb();
}

class _EditPostWeb extends State<EditPost> {
  Uint8List? _imageToCrop;
  Uint8List? _croppedImage;

  final GlobalKey _cropperKey = GlobalKey(debugLabel: "cropperKey");
  final OverlayType _overlayType = OverlayType.rectangle;

  @override
  void initState() {
    super.initState();
    _pickImageFromWeb();
  }

  void _pickImageFromWeb() {
    // TODO add image picker for web
    // final html.FileUploadInputElement uploadInput =
    //     html.FileUploadInputElement()
    // ..accept = "image/*"
    // ..click();
    // uploadInput.onChange.listen((final event) {
    //   final file = uploadInput.files?.first;
    //   if (file != null) {
    //     final reader = html.FileReader()
    //     ..readAsArrayBuffer(file);
    //     reader.onLoadEnd.listen((final _) {
    //       setState(() {
    //         _imageToCrop = reader.result as Uint8List?;
    //       });
    //     });
    //   }
    // });
  }

  @override
  Widget build(final BuildContext context) {
    if (widget.selected) {
      Cropper.crop(
        cropperKey: _cropperKey,
      ).then((final imageBytes) {
        if (imageBytes != null) {
          _croppedImage = imageBytes;
          widget.callback(_croppedImage);
        }
      });
    }

    return SafeArea(
      bottom: false,
      child: _imageToCrop != null
          ? Cropper(
              backgroundColor: Colors.transparent,
              cropperKey: _cropperKey,
              overlayType: _overlayType,
              rotationTurns: 0,
              image: Image.memory(_imageToCrop!),
              onScaleStart: (final _) {},
              onScaleUpdate: (final _) {},
              onScaleEnd: (final _) {},
            )
          : const Center(child: Text("No image selected.")),
    );
  }
}
