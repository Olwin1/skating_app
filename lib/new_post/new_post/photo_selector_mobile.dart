import "dart:typed_data";

import "package:device_info_plus/device_info_plus.dart";
import "package:flutter/material.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/misc/supported_platforms/platform_io.dart";
import "package:patinka/new_post/new_post/photos_grid_view.dart";
import "package:permission_handler/permission_handler.dart";
import "package:photo_gallery/photo_gallery.dart";

/// A platform-specific photo selector widget for mobile devices.
///
/// Displays a grid of photo albums and a preview of the selected photo.
class PlatformPhotoSelector extends StatefulWidget {
  const PlatformPhotoSelector({required this.onImageSelected, super.key});
  final Function onImageSelected;

  @override
  State<PlatformPhotoSelector> createState() => _PlatformPhotoSelectorState();
}

class _PlatformPhotoSelectorState extends State<PlatformPhotoSelector> {
  /// Whether the UI is still loading data (e.g. waiting on permissions).
  bool _loading = true;

  /// The list of photo albums fetched from the device.
  List<Album> _albums = [];

  /// The bytes of the currently selected image for preview.
  Uint8List? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Start the async initialization process when the widget mounts.
    initAsync();
  }

  /// Loads an image by its ID from the gallery and stores its bytes.
  void _loadImage(final String selectedImageId) async {
    final media = await PhotoGallery.getMedium(mediumId: selectedImageId);
    final file = await media.getFile();
    final bytes = await file.readAsBytes();
    commonLogger.i("message");
    widget.onImageSelected(bytes);

    setState(() {
      _selectedImage = bytes;
    });
  }

  /// Initializes the photo selector by requesting permissions and fetching albums.
  Future<void> initAsync() async {
    if (await _promptPermissionSetting()) {
      // Load all photo albums on the device.
      final List<Album> albums = await PhotoGallery.listAlbums(
        mediumType: MediumType.image,
      );

      // Load the first image for the initial preview.
      final MediaPage imagePage = await albums[0].listMedia(take: 1);

      setState(() {
        _albums = albums;
        _loadImage(imagePage.items.first.id);
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  /// Requests the necessary permissions for accessing photos and videos.
  ///
  /// Handles differences between Android API levels.
  Future<bool> _promptPermissionSetting() async {
    final deviceInfo = DeviceInfoPlugin();

    final androidInfo = await deviceInfo.androidInfo;

    // Handle permission logic differently depending on platform and SDK version:
    if (!isAndroidPlatform &&
            await Permission.storage.request().isGranted &&
            await Permission.photos.request().isGranted ||
        isAndroidPlatform &&
            androidInfo.version.sdkInt < 33 &&
            await Permission.storage.request().isGranted ||
        isAndroidPlatform &&
            androidInfo.version.sdkInt >= 33 &&
            await Permission.photos.request().isGranted) {
      // Also request video permission for completeness
      await Permission.videos.request();
      return true;
    }

    return false;
  }

  @override
  Widget build(final BuildContext context) {
    if (_loading) {
      // Show a loading indicator while waiting on permissions or albums.
      return const CircularProgressIndicator();
    }

    if (_albums.isEmpty) {
      // Display message if no albums were found.
      return const Text("No albums found");
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top + 10;
    final totalPadding = topPadding + 10;

    // Divide the screen into a top preview and a bottom grid:
    final topHeight = (screenHeight - totalPadding) / 3;
    final bottomHeight = ((screenHeight - totalPadding) / 3) * 2;

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        spacing: 10,
        children: [
          // Display the currently selected image preview, if any.
    _selectedImage == null?
      const SizedBox.shrink():
    

          SizedBox(
                  height: topHeight,
                  child: Image.memory(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
              ),

          // Display the grid of photos.
          SizedBox(
            height: bottomHeight,
            child: PhotosGridView(
              albums: _albums,
              update: _loadImage,
            ),
          ),
        ],
      ),
    );
  }
}
