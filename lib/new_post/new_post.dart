import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:skating_app/new_post/edit_post.dart';
import 'package:skating_app/new_post/send_post.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../current_tab.dart';

// Define the NewPost widget which extends StatefulWidget

List<Album>? _albums; // A nullable list of Album objects.

// Define a new StatelessWidget called FriendsTracker
class NewPost extends StatelessWidget {
  // Constructor for NewPost, which calls the constructor for its superclass (StatelessWidget)
  const NewPost({super.key});

  // Override the build method of StatelessWidget to return a Consumer widget
  @override
  Widget build(BuildContext context) {
    // Use the Consumer widget to listen for changes to the CurrentPage object
    return Consumer<CurrentPage>(
      builder: (context, currentPage, widget) =>
          // If the CurrentPage's tab value is 2 (New Post Page), return a NewPostPage widget
          currentPage.tab == 2
              ? const NewPostPage()
              :
              // Otherwise, return an empty SizedBox widget
              const SizedBox.shrink(),
    );
  }
}

class NewPostPage extends StatefulWidget {
  const NewPostPage({Key? key}) : super(key: key);

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

  void _update(String id) {
    setState(() => _selectedImage = id);
  }

  // This function loads the initial set of images.
  Future<void> initAsync() async {
    print(1); // Print 1.
    if (await _promptPermissionSetting()) {
      // Check if the user has granted permission to access the device's photo gallery.
      List<Album> albums = await PhotoGallery.listAlbums(
          mediumType: MediumType.image); // Load all albums that contain images.
      MediaPage imagePage = await albums[0].listMedia(
        skip: 0,
        take: 1,
      ); // Load the first page of images from the first album.
      setState(() {
        _selectedImage = imagePage.items.first
            .id; // Set _selectedImage to the ID of the first image in the first page.
        _albums = albums; // Assign the albums list to _albums.
        _loading = false; // Set _loading to false.
      });
    }

    setState(() {
      _loading = false; // Set _loading to false.
    });
  }

// This function prompts the user to grant permission to access the device's photo gallery.
  Future<bool> _promptPermissionSetting() async {
    print(5); // Print 5.
    // Check if the device is iOS and both the storage and photos permissions have been granted,
    // or if the device is Android and the storage permission has been granted.
    if (Platform.isIOS &&
            await Permission.storage.request().isGranted &&
            await Permission.photos.request().isGranted ||
        Platform.isAndroid && await Permission.storage.request().isGranted) {
      return true; // Return true if the permissions have been granted.
    }
    return false; // Return false if the permissions have not been granted.
  }

  callback(image) {
    print("i gets an imaen");
    selectedImage = image;
    Navigator.of(context, rootNavigator: true).push(
        // Root navigator hides navbar
        // Send to Save Session page
        MaterialPageRoute(
            builder: (context) => SendPost(
                  image: selectedImage!,
                )));
    setState(() {
      selected = false;
    });
  }

  @override
  // Build the UI for the NewPost widget
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Post"),
        actions: [
          IconButton(
              onPressed: () => _selectedImage != null
                  ? {
                      setState(
                        () => selected = true,
                      ),
                      if (selectedImage != null)
                        {print("image has been selcected")}
                    }
                  : print("No image selected"),
              icon: const Icon(Icons.arrow_forward))
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // A container that displays the selected image
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: EditPost(
                    selected: selected,
                    selectedImage: _selectedImage!,
                    callback: callback,
                  )),
              const Spacer(),
              // A layout builder that displays a grid of images from the photo gallery
              LayoutBuilder(
                builder: (context, constraints) {
                  // Determines the width and height of each grid item based on the constraints
                  return SizedBox(
                      height: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).size.width -
                          180,
                      child: PhotosGridView(
                        update: _update,
                      ));
                },
              ),
            ]),
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
      // Loads the next page of images from the first album, skipping `pageKey` items and taking `_pageSize` items.
      final page = await _albums![0].listMedia(
        skip: pageKey,
        take: _pageSize,
      );
      final newItems = page.items;
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        // appendLastPage is called if there are no more items to load
        _pagingController.appendLastPage(newItems);
      } else {
        // appendPage is called to add the newly loaded items to the list of items
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
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
                  color: Colors.grey[300],
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
