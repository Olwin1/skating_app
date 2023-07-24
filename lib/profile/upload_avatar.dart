import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:http/http.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:patinka/api/social.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/new_post/avatar_interact.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../api/image.dart';
import '../swatch.dart';

// Define the NewPost widget which extends StatefulWidget

List<Album>? _albums; // A nullable list of Album objects.

class ChangeAvatarPage extends StatefulWidget {
  const ChangeAvatarPage({Key? key}) : super(key: key);

  @override
  // Create the state for the NewPost widget
  State<ChangeAvatarPage> createState() => _ChangeAvatarPage();
}

String? _selectedImage;

// Define the state for the NewPost widget
// This class is the state of a widget named NewPost.
class _ChangeAvatarPage extends State<ChangeAvatarPage> {
  bool selected = false;
  Uint8List? selectedImage;
  // A string variable to hold the selected image ID.
  bool _loading =
      false; // A boolean variable to indicate whether the widget is currently loading.
  List<GestureDetector> loadedImages = []; // A list of GestureDetector widgets.

  // This function is called when the widget is first created.
  @override
  void initState() {
    super.initState();
    _loading = true; // Set _loading to true.
    initAsync(); // Call the initAsync function.
  }

  void _update(String id) {
    mounted ? setState(() => _selectedImage = id) : null;
  }

  // This function loads the initial set of images.
  Future<void> initAsync() async {
    commonLogger.d("Running initAsync");
    if (await _promptPermissionSetting()) {
      // Check if the user has granted permission to access the device's photo gallery.
      List<Album> albums = await PhotoGallery.listAlbums(
          mediumType: MediumType.image); // Load all albums that contain images.
      MediaPage imagePage = await albums[0].listMedia(
        skip: 0,
        take: 1,
      ); // Load the first page of images from the first album.
      mounted
          ? setState(() {
              _selectedImage = imagePage.items.first
                  .id; // Set _selectedImage to the ID of the first image in the first page.
              _albums = albums; // Assign the albums list to _albums.
              _loading = false; // Set _loading to false.
            })
          : null;
    }

    mounted
        ? setState(() {
            _loading = false; // Set _loading to false.
          })
        : null;
  }

// This function prompts the user to grant permission to access the device's photo gallery.
  Future<bool> _promptPermissionSetting() async {
    commonLogger.v("Prompting image permissions");
    // Check if the device is iOS and both the storage and photos permissions have been granted,
    // or if the device is Android and the storage permission has been granted.
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (Platform.isIOS &&
            await Permission.storage.request().isGranted &&
            await Permission.photos.request().isGranted ||
        Platform.isAndroid &&
            androidInfo.version.sdkInt < 33 &&
            await Permission.storage.request().isGranted ||
        Platform.isAndroid &&
            androidInfo.version.sdkInt >= 33 &&
            await Permission.photos.request().isGranted) {
      await Permission.videos.request();
      commonLogger.d("Permissions are true");

      return true; // Return true if the permissions have been granted.
    }
    return false; // Return false if the permissions have not been granted.
  }

  Future<String?> sendImage(image) async {
    try {
      // Upload the image file
      StreamedResponse? response = await uploadFile(image);
      String? id = await response?.stream.bytesToString();
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

  void sendInfo(image) async {
    try {
      showDialog(
        useRootNavigator: false,
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: swatch[800]!,
            title: Text(
              'Processing',
              style: TextStyle(color: swatch[701]),
            ),
            content: Text(
              'Please wait...',
              style: TextStyle(color: swatch[901]),
            ),
          );
        },
      );
      // Call the "sendImage" function and wait for it to complete
      String? imageId = await sendImage(image);
      // When "sendImage" completes successfully, call "postPost"
      // with the text from "descriptionController" and the returned value
      if (imageId != null) {
        await setAvatar(imageId);
        // Wait for "postPost" to complete successfully
        // When "postPost" completes successfully, close the current screen
        if (mounted) Phoenix.rebirth(context);
      }
    } catch (e) {
      commonLogger.e("Error creating post: $e");
    }
  }

  void callback(image) {
    commonLogger.v("Navigating to send post page");

    selectedImage = image;
    sendInfo(image);
    mounted
        ? setState(() {
            selected = false;
          })
        : null;
  }

  @override
  // Build the UI for the NewPost widget
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Avatar"),
        actions: [
          IconButton(
              onPressed: () => _selectedImage != null
                  ? {
                      mounted
                          ? setState(
                              () => selected = true,
                            )
                          : null,
                      if (selectedImage != null)
                        {commonLogger.i("No image has been selected")}
                    }
                  : commonLogger.i("No image has been selected."),
              icon: const Icon(Icons.arrow_forward))
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: const AssetImage("assets/backgrounds/graffiti.png"),
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomLeft,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5), BlendMode.srcOver)),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A container that displays the selected image
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: AvatarInteract(
                          selected: selected,
                          selectedImage: _selectedImage!,
                          callback: callback,
                        )),
                    //const Spacer(),
                    // A layout builder that displays a grid of images from the photo gallery
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Determines the width and height of each grid item based on the constraints
                        return SizedBox(
                            height: MediaQuery.of(context).size.height -
                                MediaQuery.of(context).size.width -
                                140,
                            child: PhotosGridView(
                              update: _update,
                            ));
                      },
                    ),
                  ])),
    );
  }
}

class PhotosGridView extends StatefulWidget {
  const PhotosGridView({super.key, required this.update});
  final ValueChanged<String> update;

  @override
  State<PhotosGridView> createState() => _PhotosGridViewState();
}

class _PhotosGridViewState extends State<PhotosGridView> {
  static const _pageSize = 20; // Number of items to load in a single page

  // PagingController manages the loading of pages as the user scrolls
  final PagingController<int, Medium> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    // addPageRequestListener is called whenever the user scrolls near the end of the list
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  // Fetches the data for the given pageKey and appends it to the list of items
  Future<void> _fetchPage(int pageKey) async {
    try {
      if (_albums != null) {
        // Loads the next page of images from the first album, skipping `pageKey` items and taking `_pageSize` items.
        final page = await _albums![0].listMedia(
          skip: pageKey,
          take: _pageSize,
        );
        final newItems = page.items;
        final isLastPage = newItems.length < _pageSize;
        if (!mounted) return;
        if (isLastPage) {
          // appendLastPage is called if there are no more items to load
          _pagingController.appendLastPage(newItems);
        } else {
          // appendPage is called to add the newly loaded items to the list of items
          final nextPageKey = pageKey + newItems.length;
          _pagingController.appendPage(newItems, nextPageKey);
        }
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) => PagedGridView<int, Medium>(
        // Uses the SliverGridDelegateWithMaxCrossAxisExtent to layout the grid
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          childAspectRatio: 1, // Ratio of width to height of grid items
          mainAxisSpacing: 5, // Space between rows of grid items
          crossAxisSpacing: 5, // Space between columns of grid items
          maxCrossAxisExtent: MediaQuery.of(context).size.width /
              4, // Maximum width of a grid item
        ),
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Medium>(
          itemBuilder: (context, item, index) => GestureDetector(
              onTap: () => widget.update(
                  // Updates the selected image when an image is tapped
                  item.id),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Container(
                  color: shimmer["base"]!,
                  child: FadeInImage(
                    fit: BoxFit.cover,
                    placeholder: MemoryImage(kTransparentImage),
                    // Uses the ThumbnailProvider to display the grid image
                    image: ThumbnailProvider(
                      mediumId: item.id,
                      mediumType: item.mediumType,
                      highQuality: false,
                    ),
                  ),
                ),
              )),
        ),
      );

  @override
  void dispose() {
    // Disposes of the PagingController to free up resources
    _pagingController.dispose();
    super.dispose();
  }
}
