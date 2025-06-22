import "package:device_info_plus/device_info_plus.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:infinite_scroll_pagination/infinite_scroll_pagination.dart";
import "package:patinka/api/config/config.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/misc/supported_platforms/platform_stub.dart";
import "package:patinka/new_post/edit_post/edit_post_mobile.dart";
import "package:patinka/new_post/send_post.dart";
import "package:patinka/services/navigation_service.dart";
import "package:patinka/social_media/utils/components/list_view/paging_controller.dart";
import "package:patinka/swatch.dart";
import "package:permission_handler/permission_handler.dart";
import "package:photo_gallery/photo_gallery.dart";
import "package:provider/provider.dart";
import "package:transparent_image/transparent_image.dart";

// Define the NewPost widget which extends StatefulWidget

List<Album>? _albums; // A nullable list of Album objects.

// Define a new StatelessWidget called FriendsTracker
class NewPost extends StatelessWidget {
  // Constructor for NewPost, which calls the constructor for its superclass (StatelessWidget)
  const NewPost({super.key});

  // Override the build method of StatelessWidget to return a Consumer widget
  @override
  Widget build(final BuildContext context) => Consumer<NavigationService>(
      builder: (final context, final navigationService, final _) =>
          NavigationService.getCurrentIndex == 2
              ? const NewPostPage()
              :
              // Otherwise, return an empty SizedBox widget
              const SizedBox.shrink());
}

class NewPostPage extends StatefulWidget {
  const NewPostPage({super.key});

  @override
  // Create the state for the NewPost widget
  State<NewPostPage> createState() => _NewPostPage();
}

String? _selectedImage;

// Define the state for the NewPost widget
// This class is the state of a widget named NewPost.
class _NewPostPage extends State<NewPostPage> {
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
      commonLogger.d("Permissions confirmed runnning rest");

      // Check if the user has granted permission to access the device's photo gallery.
      final List<Album> albums = await PhotoGallery.listAlbums(
          mediumType: MediumType.image); // Load all albums that contain images.
      commonLogger.d("Available albulms are: $albums");

      final MediaPage imagePage = await albums[0].listMedia(
        skip: 0,
        take: 1,
      ); // Load the first page of images from the first album.
      commonLogger
        ..d("Available images are: $imagePage")
        ..d("Still mounted? $mounted");

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
    if (isMobilePlatform) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
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
        commonLogger.d("Permissions are true");
      }

      return true; // Return true if the permissions have been granted.
    }
    commonLogger.d("Permissions are false");

    return false; // Return false if the permissions have not been granted.
  }

  void callback(final Uint8List image) {
    commonLogger.t("Navigating to send post page");

    selectedImage = image;
    Navigator.of(context).push(
      // Root navigator hides navbar
      // Send to Send Post page
      PageRouteBuilder(
        pageBuilder:
            (final context, final animation, final secondaryAnimation) =>
                SendPost(
          image: selectedImage!,
        ),
        opaque: false,
        transitionsBuilder: (final context, final animation,
            final secondaryAnimation, final child) {
          const begin = 0.0;
          const end = 1.0;
          final tween = Tween(begin: begin, end: end);
          final fadeAnimation = tween.animate(animation);
          return FadeTransition(
            opacity: fadeAnimation,
            child: child,
          );
        },
      ),
    );
    mounted
        ? setState(() {
            selected = false;
          })
        : null;
  }

  @override
  // Build the UI for the NewPost widget
  Widget build(final BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          iconTheme: IconThemeData(color: swatch[701]),
          elevation: 8,
          shadowColor: Colors.green.shade900,
          backgroundColor: Config.appbarColour,
          foregroundColor: Colors.transparent,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          title: Text(
            "New Post",
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
                      _selectedImage == null
                          ? const SizedBox.shrink()
                          : Center(
                              child: EditPost(
                                selected: selected,
                                selectedImage: _selectedImage!,
                                callback: callback,
                              ),
                            ),
                      Expanded(
                          flex: 6,
                          child: PhotosGridView(
                            update: _update,
                          ))
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
  // Define method for getPage to run every time a new page needs to be fetched
  Future<List<Medium>?> _getNextPage(
      final int newKey, final int pageSize) async {
    final newItems = (await _albums![0].listMedia(
      skip: newKey,
      take: pageSize,
    ))
        .items;
    return newItems;
  }

  // GenericStateController manages the loading of pages as the user scrolls
  GenericStateController<Medium> genericStateController =
      GenericStateController<Medium>(
    key: const Key("photos-grid"),
  );

  @override
  void initState() {
    genericStateController.init(
        this,
        (final newState) =>
            setState(() => genericStateController.pagingState = newState),
        _getNextPage,
        _getLastPage);
    super.initState();
  }

  // Define _getLastPage which will be called only after fetch page and only on the last time.
  List<Medium> _getLastPage(final List<Medium> pages) {
    final Medium padderItem = Medium.fromJson(const {
      "id": "0",
      "filename": "a",
      "title": "a",
      "width": 1,
      "height": 1,
      "size": 1,
      "orientation": 1,
      "mimeType": "image/jpeg"
    });
    // Add padding to bottom row of items.
    final int rem = 5 - ((pages.length) + pages.length) % 4;
    final List<Medium> spacers = [];
    for (int i = 0; i < rem; i++) {
      spacers.add(padderItem);
    }
    return spacers;
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
        state: genericStateController.pagingState,
        fetchNextPage: genericStateController.getNextPage,
        builderDelegate: PagedChildBuilderDelegate<Medium>(
          itemBuilder: (final context, final item, final index) =>
              item.id == "0" &&
                      item.filename == "a" &&
                      item.title == "a" &&
                      item.width == 1 &&
                      item.height == 1 &&
                      item.size == 1 &&
                      item.orientation == 1
                  ? const SizedBox(
                      height: 72,
                    )
                  : GestureDetector(
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
}
