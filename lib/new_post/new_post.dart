import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:patinka/api/config/config.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/new_post/edit_post/edit_post.dart";
import "package:patinka/new_post/new_post/platform_photo_selector.dart";
import "package:patinka/services/navigation_service.dart";
import "package:patinka/swatch.dart";
import "package:provider/provider.dart";

// Define the NewPost widget which extends StatefulWidget

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

Uint8List? _selectedImage;

// Define the state for the NewPost widget
// This class is the state of a widget named NewPost.
class _NewPostPage extends State<NewPostPage> {
  bool selected = false;
  void onImageSelected(final Uint8List newImage) {
    _selectedImage = newImage;
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
                      Navigator.push(
                        NavigationService.currentNavigatorKey.currentContext!,
                        MaterialPageRoute(
                          builder: (final context) => EditPost(
                              selectedImage: _selectedImage!),
                        ),
                      )
                    }
                  : commonLogger.i("No image has been selected."),
              icon: const Icon(Icons.arrow_forward))
        ],
      ),
      body: Column(children: [
        PlatformPhotoSelector(
          onImageSelected: onImageSelected,
        ),
      ]));
}
