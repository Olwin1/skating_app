import 'dart:io'; // Import the dart:io library for accessing the file system.
import 'dart:typed_data'; // Import the dart:typed_data library for working with low-level byte data.

import 'package:cropperx/cropperx.dart'; // Import the CropperX package for image cropping functionality.
import 'package:flutter/material.dart'; // Import the Flutter Material library for building UI components.
import 'package:flutter/services.dart'; // Import the Flutter Services library for platform-specific services.
import 'package:photo_gallery/photo_gallery.dart'; // Import the Photo Gallery package for working with device photo galleries.

// Define the EditPost widget which extends StatefulWidget
class EditPost extends StatefulWidget {
  final Function
      callback; // A function to be called when the image has been edited and confirmed.
  final bool
      selected; // A boolean indicating whether this widget is currently selected (in focus).

  // Constructor for the EditPost widget.
  const EditPost({
    super.key, // A key to identify this widget.
    required this.selectedImage, // The ID of the selected image.
    required this.selected, // Whether this widget is currently selected.
    required this.callback, // The function to call when editing is complete.
  });

  // The ID of the selected image.
  final String selectedImage;

  @override
  // Create the state for the EditPost widget.
  State<EditPost> createState() => _EditPost();
}

// Define the state for the EditPost widget.
class _EditPost extends State<EditPost> {
  ImageProvider? provider; // The provider for the selected image.
  Uint8List? _imageToCrop; // The byte data for the image to be cropped.
  Uint8List? _croppedImage; // The byte data for the cropped image.
  String initialSelection = "0"; // The initial selection (default: first item).

  @override
  void initState() {
    // Initialize the state of the widget.
    provider = PhotoProvider(
        mediumId:
            widget.selectedImage); // Set the provider for the selected image.
    getAssetImage().then((value) => {
          mounted
              ? setState(() => {
                    initialSelection = widget.selectedImage,
                    _imageToCrop = value, // Set the image data to be cropped.
                  })
              : null,
        }); // Load the image data asynchronously.

    super.initState();
  }

  final GlobalKey _cropperKey =
      GlobalKey(debugLabel: 'cropperKey'); // The key for the Cropper widget.
  final OverlayType _overlayType =
      OverlayType.rectangle; // The type of overlay for the Cropper.
  final int _rotationTurns = 0; // The number of turns to rotate the image.

  @override
  Widget build(BuildContext context) {
    // Build the UI for the widget.
    if (initialSelection != widget.selectedImage) {
      // If the selection has changed,
      getAssetImage().then((value) => {
            mounted
                ? setState(() => {
                      initialSelection = widget.selectedImage,
                      _imageToCrop =
                          value, // Update the image data to be cropped.
                    })
                : null,
          }); // Load the image data asynchronously.
    }
    if (widget.selected) {
      // If this widget is currently selected,
      Cropper.crop(
        cropperKey: _cropperKey, // Set the key for the Cropper widget.
      ).then((imageBytes) => {
            if (imageBytes != null)
              {
                _croppedImage = imageBytes,
                widget.callback(
                    _croppedImage), // Call the callback function with the cropped image data.
              }
          }); // Crop the image asynchronously.
    }
// This provides padding that avoids any
// intrusive display areas, such as notches, camera holes, or device margins.
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // A SizedBox with a fixed height that contains the image cropper widget.
            // If _imageToCrop is not null, then the Cropper widget is displayed;
            // otherwise, a pink ColoredBox is displayed.
            OrientationBuilder(builder: (context, orientation) {
              return SizedBox(
                width: orientation == Orientation.portrait
                    ? MediaQuery.of(context).size.height * 0.4
                    : MediaQuery.of(context).size.height,
                height: orientation == Orientation.portrait
                    ? MediaQuery.of(context).size.height * 0.4
                    : MediaQuery.of(context)
                        .size
                        .height, // Adjust the height as needed
                child: _imageToCrop != null
                    ? Cropper(
                        backgroundColor: Colors.transparent,
                        cropperKey: _cropperKey,
                        overlayType: _overlayType,
                        rotationTurns: _rotationTurns,
                        image: Image.memory(_imageToCrop!),
                        onScaleStart: (details) {
                          // todo: define started action.
                        },
                        onScaleUpdate: (details) {
                          // todo: define updated action.
                        },
                        onScaleEnd: (details) {
                          // todo: define ended action.
                        },
                      )
                    : const ColoredBox(color: Colors.pink),
              );
            }),
            const SizedBox(
              height: 16,
            )
          ],
        ),
      ),
    );
  }

// A method that sets the provider and updates the state of the widget.
  void setProvider(ImageProvider provider) {
    this.provider = provider;
    mounted ? setState(() {}) : null;
  }

// A method that sets the provider back to the original photo
// and updates the state of the widget.
  void restore() {
    setProvider(PhotoProvider(mediumId: widget.selectedImage));
  }

// A method that gets the image data as a Uint8List from the device's asset storage.
  Future<Uint8List> getAssetImage() async {
    // Get the Medium object from the PhotoGallery using the mediumId.
    final Medium medium = await PhotoGallery.getMedium(
      mediumId: widget.selectedImage,
    );
    // Get the file containing the Medium data.
    final File byteData = await medium.getFile();
    // Read the file data as bytes and return it as a Uint8List.
    return byteData.readAsBytesSync();
  }
}
