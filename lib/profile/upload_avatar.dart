import "dart:io";

import "package:device_info_plus/device_info_plus.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_phoenix/flutter_phoenix.dart";
import "package:http/http.dart";
import "package:infinite_scroll_pagination/infinite_scroll_pagination.dart";
import "package:patinka/api/image.dart";
import "package:patinka/api/social.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/new_post/avatar_interact.dart";
import "package:patinka/swatch.dart";
import "package:permission_handler/permission_handler.dart";
import "package:photo_gallery/photo_gallery.dart";
import "package:transparent_image/transparent_image.dart";

// Define the NewPost widget which extends StatefulWidget

List<Album>? _albums; // A nullable list of Album objects.

class ChangeAvatarPage extends StatefulWidget {
  const ChangeAvatarPage({super.key});

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

  void _update(final String id) {
    mounted ? setState(() => _selectedImage = id) : null;
  }

  // This function loads the initial set of images.
  Future<void> initAsync() async {
    commonLogger.d("Running initAsync");
    if (await _promptPermissionSetting()) {
      // Check if the user has granted permission to access the device's photo gallery.
      final List<Album> albums = await PhotoGallery.listAlbums(
          mediumType: MediumType.image); // Load all albums that contain images.
      final MediaPage imagePage = await albums[0].listMedia(
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
    commonLogger.t("Prompting image permissions");
    // Check if the device is iOS and both the storage and photos permissions have been granted,
    // or if the device is Android and the storage permission has been granted.
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
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

  void callback(final Uint8List image) {
    commonLogger.t("Navigating to send post page");

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
  Widget build(final BuildContext context) => Scaffold(
        backgroundColor: const Color(0x24000000),
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          iconTheme: IconThemeData(color: swatch[701]),
          elevation: 0,
          shadowColor: Colors.green.shade900,
          backgroundColor: const Color(0xa4000000),
          foregroundColor: Colors.transparent,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          title: Text(
            "New Avatar",
            style: TextStyle(color: swatch[701]),
          ),
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
                          builder: (final context, final constraints) =>
                              SizedBox(
                                  height: MediaQuery.of(context).size.height -
                                      MediaQuery.of(context).size.width -
                                      150,
                                  child: PhotosGridView(
                                    update: _update,
                                  ))),
                    ])),
      );
}

class PhotosGridView extends StatefulWidget {
  const PhotosGridView({required this.update, super.key});
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
    _pagingController.addPageRequestListener(_fetchPage);
    super.initState();
  }

  // Fetches the data for the given pageKey and appends it to the list of items
  Future<void> _fetchPage(final int pageKey) async {
    try {
      if (_albums != null) {
        // Loads the next page of images from the first album, skipping `pageKey` items and taking `_pageSize` items.
        final page = await _albums![0].listMedia(
          skip: pageKey,
          take: _pageSize,
        );
        final newItems = page.items;
        final isLastPage = newItems.length < _pageSize;
        if (!mounted) {
          return;
        }
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
  Widget build(final BuildContext context) => PagedGridView<int, Medium>(
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
          itemBuilder: (final context, final item, final index) =>
              GestureDetector(
                  onTap: () => widget.update(
                      // Updates the selected image when an image is tapped
                      item.id),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Container(
                      color: shimmer["base"],
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
