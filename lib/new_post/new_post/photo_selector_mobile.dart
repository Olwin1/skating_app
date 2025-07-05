import "dart:typed_data";

import "package:device_info_plus/device_info_plus.dart";
import "package:flutter/material.dart";
import "package:patinka/misc/supported_platforms/platform_io.dart";
import "package:patinka/new_post/new_post/photos_grid_view.dart";
import "package:permission_handler/permission_handler.dart";
import "package:photo_gallery/photo_gallery.dart";

class PlatformPhotoSelector extends StatefulWidget {
  const PlatformPhotoSelector({
    required this.onImageSelected,
    super.key,
  });

  final void Function(Uint8List image) onImageSelected;

  @override
  State<PlatformPhotoSelector> createState() => _PlatformPhotoSelectorState();
}

class _PlatformPhotoSelectorState extends State<PlatformPhotoSelector> {
  bool _loading = true;
  List<Album> _albums = [];
  String? _selectedImageId;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    if (await _promptPermissionSetting()) {
      final List<Album> albums = await PhotoGallery.listAlbums(
        mediumType: MediumType.image,
      );

      final MediaPage imagePage = await albums[0].listMedia(take: 1);
      setState(() {
        _albums = albums;
        _selectedImageId = imagePage.items.first.id;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<bool> _promptPermissionSetting() async {
    final deviceInfo = DeviceInfoPlugin();

    final androidInfo = await deviceInfo.androidInfo;
    if (!isAndroidPlatform &&
            await Permission.storage.request().isGranted &&
            await Permission.photos.request().isGranted ||
        isAndroidPlatform &&
            androidInfo.version.sdkInt < 33 &&
            await Permission.storage.request().isGranted ||
        isAndroidPlatform &&
            androidInfo.version.sdkInt >= 33 &&
            await Permission.photos.request().isGranted) {
      await Permission.videos.request();
      return true;
    }

    return false;
  }

  Future<void> _loadImage(final String id) async {
    final media = await PhotoGallery.getMedium(mediumId: id);
    final file = await media.getFile();
    final bytes = await file.readAsBytes();
    widget.onImageSelected(bytes);
  }

  @override
  Widget build(final BuildContext context) {
    if (_loading) {
      return const CircularProgressIndicator();
    }

    if (_albums.isEmpty) {
      return const Text("No albums found");
    }

    return PhotosGridView(
      albums: _albums,
      update: _loadImage,
    );
  }
}
