import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:skating_app/objects/user.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:transparent_image/transparent_image.dart';

// Define the NewPost widget which extends StatefulWidget
class NewPost extends StatefulWidget {
  const NewPost({Key? key, required this.title}) : super(key: key);
  // title is a required parameter
  final String title;

  @override
  // Create the state for the NewPost widget
  State<NewPost> createState() => _NewPost();
}

// Define the state for the NewPost widget
// This class is the state of a widget named NewPost.
class _NewPost extends State<NewPost> {
  String _selectedImage =
      "0"; // A string variable to hold the selected image ID.
  List<Album>? _albums; // A nullable list of Album objects.
  List<MediaPage>? _images; // A nullable list of MediaPage objects.
  bool _loading =
      false; // A boolean variable to indicate whether the widget is currently loading.
  int _itemCount = 0; // An integer variable to hold the total number of images.
  List<GestureDetector> loadedImages = []; // A list of GestureDetector widgets.

  // This function is called when the widget is first created.
  @override
  void initState() {
    super.initState();
    _loading = true; // Set _loading to true.
    initAsync(); // Call the initAsync function.
  }

  int skip =
      0; // An integer variable to hold the number of items to skip when loading images.

  // This function loads the initial set of images.
  Future<void> initAsync() async {
    print(1); // Print 1.
    if (await _promptPermissionSetting()) {
      // Check if the user has granted permission to access the device's photo gallery.
      print(2); // Print 2.
      List<Album> albums = await PhotoGallery.listAlbums(
          mediumType: MediumType.image); // Load all albums that contain images.
      MediaPage imagePage = await albums[0].listMedia(
        skip: skip,
        take: 20,
      ); // Load the first page of images from the first album.
      setState(() {
        print(3); // Print 3.
        _images = [imagePage]; // Assign the imagePage to _images.
        _selectedImage = _images![0]
            .items
            .first
            .id; // Set _selectedImage to the ID of the first image in the first page.
        _albums = albums; // Assign the albums list to _albums.
        _loading = false; // Set _loading to false.
        _itemCount = _images![0]
            .items
            .length; // Set _itemCount to the number of items in the first page.
      });
    }

    setState(() {
      print(4); // Print 4.
      _loading = false; // Set _loading to false.
    });
  }

  // This function loads the next page of images.
  Future<void> nextPage() async {
    List<Album> albums = await PhotoGallery.listAlbums(
        mediumType: MediumType.image); // Load all albums that contain images.
    MediaPage _data = await albums[0].listMedia(
      skip: skip,
      take: 20,
    ); // Load the next page of images from the first album.
    setState(() {
      _images = [
        ..._images!,
        _data
      ]; // Append the new page of images to the _images list.
      _itemCount += _data.items
          .length; // Update _itemCount to include the number of items in the new page.
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
      print(6); // Print 6.
      return true; // Return true if the permissions have been granted.
    }
    print(7); // Print 7.
    return false; // Return false if the permissions have not been granted.
  }

  @override
  // Build the UI for the NewPost widget
  Widget build(BuildContext context) {
    // Create an instance of the User object
    User user = User("1");

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Post"),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(children: [
              // A container that displays the selected image
              Container(
                width: MediaQuery.of(context).size.width,
                child: FadeInImage(
                  height: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                  placeholder: MemoryImage(kTransparentImage),
                  // Uses the PhotoProvider to display the selected image
                  image: PhotoProvider(mediumId: _selectedImage),
                ),
              ),
              const Spacer(),
              // A layout builder that displays a grid of images from the photo gallery
              LayoutBuilder(
                builder: (context, constraints) {
                  // Determines the width and height of each grid item based on the constraints
                  double gridWidth = (constraints.maxWidth - 25) / 4;
                  double gridHeight = gridWidth;
                  double ratio = gridWidth / gridHeight;
                  return SizedBox(
                    height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).size.width -
                        180,
                    child: GridView.builder(
                        reverse: false,
                        itemCount: _itemCount,
                        // Uses the SliverGridDelegateWithMaxCrossAxisExtent to layout the grid
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          childAspectRatio: ratio,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                          maxCrossAxisExtent:
                              MediaQuery.of(context).size.width / 4,
                        ),
                        // Builds each grid item
                        itemBuilder: (BuildContext ctx, index) {
                          if (index < _itemCount) {
                            // Adds each loaded image to the loadedImages list
                            for (var i = 0; i < _images!.length; i++) {
                              print("not loading index: " +
                                  index.toString() +
                                  " skip: " +
                                  skip.toString() +
                                  " len: " +
                                  _itemCount.toString());
                              loadedImages.add(GestureDetector(
                                onTap: () => setState(() {
                                  // Updates the selected image when an image is tapped
                                  _selectedImage =
                                      _images![i].items[index].id.toString();
                                }),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: Container(
                                    color: Colors.grey[300],
                                    height: gridWidth,
                                    width: gridWidth,
                                    child: FadeInImage(
                                      fit: BoxFit.cover,
                                      placeholder:
                                          MemoryImage(kTransparentImage),
                                      // Uses the ThumbnailProvider to display the grid image
                                      image: ThumbnailProvider(
                                        mediumId: _images![i].items[index].id,
                                        mediumType:
                                            _images?[i].items[index].mediumType,
                                        highQuality: false,
                                      ),
                                    ),
                                  ),
                                ),
                              ));
                            }
                            // Displays the loaded image at the current index
                            return loadedImages[index];
                          } else {
                            // Displays a progress indicator while the next page of images is loading
                            print("loading pls");

                            nextPage();
                            skip += 20;
                            return const CircularProgressIndicator();
                          }
                        }),
                  );
                },
              ),
            ]),
    );
  }
}
