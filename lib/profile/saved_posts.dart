import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay/flutter_overlay.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/api/social.dart';
import 'package:patinka/common_logger.dart';
import '../api/config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../components/list_error.dart';
import '../swatch.dart';

String? currentImage;

// Define a new StatelessWidget called SavedPosts
class SavedPosts extends StatelessWidget {
  // Constructor for SavedPosts, which calls the constructor for its superclass (StatelessWidget)
  const SavedPosts({super.key});

  // Override the build method of StatelessWidget to return a Consumer widget
  @override
  Widget build(BuildContext context) {
    GestureDetector dialog() {
      return GestureDetector(
        onTap: () {
          Navigator.pop(context, 'close');
        },
        child: currentImage != null
            ? Container(
                color: const Color(0x55000000),
                padding: const EdgeInsets.all(4),
                child: CachedNetworkImage(
                  imageUrl: '${Config.uri}/image/$currentImage',
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          8), // Set the shape of the container to a circle
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.contain),
                    ),
                  ),
                ))
            : const SizedBox.shrink(),
      );
    }

    void show() {
      HiOverlay.show(
        context,
        child: dialog(),
      ).then((value) {
        commonLogger.t('Recieved value: $value');
      });
    }

    return Scaffold(
        backgroundColor: const Color(0x77000000),
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
          // Create appBar widget
          title: Text("Saved Posts",
              style: TextStyle(color: swatch[701])), // Set title
        ),
        // Basic list layout element
        body: SavedPostsList(imageViewerController: show));
  }
}

// Creates a grid tile widget from an image URL
Widget _createGridTileWidget(Map<String, dynamic> post,
    dynamic imageViewerController, Function refreshPage) {
  return Builder(builder: (context) {
    void popNavigator() {
      Navigator.of(context).pop();
    }

    return GestureDetector(
      onLongPress: () async {
        await showDialog(
          useRootNavigator: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                backgroundColor: swatch[800],
                title: Text(
                  'Are you sure you want to unsave this post?',
                  style: TextStyle(color: swatch[701]),
                ),
                content: SizedBox(
                    height: 96,
                    child: Column(children: [
                      TextButton(
                        onPressed: () async {
                          await SocialAPI.unsavePost(post["post_id"]);
                          refreshPage();
                          popNavigator();
                        },
                        child: Text(
                          'Unsave',
                          style: TextStyle(color: swatch[901]),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          popNavigator();
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: swatch[901]),
                        ),
                      )
                    ])));
          },
        );
      },
      //onLongPressEnd: (details) => _popupDialog?.remove(),
      onTap: () => {currentImage = post["image"], imageViewerController()},
      child: CachedNetworkImage(
        imageUrl: '${Config.uri}/image/thumbnail/${post["image"]}',
        fit: BoxFit.cover,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
                8), // Set the shape of the container to a circle
            image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
          ),
        ),
      ), // Display the image from the URL
    );
  });
}

class SavedPostsList extends StatefulWidget {
  final dynamic imageViewerController;
  const SavedPostsList({super.key, required this.imageViewerController});

  @override
  State<SavedPostsList> createState() => _SavedPostsListState();
}

class _SavedPostsListState extends State<SavedPostsList> {
  // Define the page size used for pagination
  static const _pageSize = 20;

  // Create a PagingController to manage pagination
  final PagingController<int, Map<String, dynamic>> _pagingController =
      PagingController(firstPageKey: 0);

  Widget _createGridLoadingWidgets() {
    Widget child = Shimmer.fromColors(
        baseColor: shimmer["base"]!,
        highlightColor: shimmer["highlight"]!,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset("assets/placeholders/150.png"),
        ));
    return GridView(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        // Specify the properties for the grid tiles
        childAspectRatio: 1,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        maxCrossAxisExtent: MediaQuery.of(context).size.width / 3,
      ),
      children: [
        child,
        child,
        child,
        child,
        child,
        child,
        child,
        child,
        child,
        child,
        child,
        child
      ],
    );
  }

  @override
  void initState() {
    // Add a listener to the PagingController that fetches the next page when requested
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  void refreshPage() {
    _pagingController.refresh();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      // Fetch the next page of posts from the user's account
      final page = await SocialAPI.getSavedPosts(pageKey);

      // Determine if this is the last page of posts
      final isLastPage = page.length < _pageSize;

      if (isLastPage && mounted) {
        // If this is the last page of posts, append it to the PagingController as the final page
        if ((_pagingController.itemList == null ||
                _pagingController.itemList!.isEmpty) &&
            page.isEmpty) {
          _pagingController.appendLastPage(page);
        } else {
          int rem =
              4 - ((_pagingController.itemList?.length ?? 0) + page.length) % 3;
          List<Map<String, dynamic>> spacers = [];
          for (int i = 0; i < rem; i++) {
            spacers.add({"last": true});
          }
          _pagingController.appendLastPage([...page, ...spacers]);
        }
      } else if (mounted) {
        // If there are more pages of posts, append the current page to the PagingController
        // and specify the key for the next page
        final nextPageKey = pageKey += 1;
        _pagingController.appendPage(page, nextPageKey);
      }
    } catch (error) {
      // If an error occurs while fetching a page, set the PagingController's error state
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedGridView<int, Map<String, dynamic>>(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      pagingController: _pagingController,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        // Specify the properties for the grid tiles
        childAspectRatio: 1,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        maxCrossAxisExtent: MediaQuery.of(context).size.width / 3,
      ),
      builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
        firstPageProgressIndicatorBuilder: (context) =>
            _createGridLoadingWidgets(),
        noItemsFoundIndicatorBuilder: (context) =>
            const ListError(title: "No Posts Saved", body: ""),
        // Specify how to build each grid tile
        itemBuilder: (context, item, index) => item["last"] == true
            ? const SizedBox(
                height: 72,
              )
            : _createGridTileWidget(
                item["posts"], widget.imageViewerController, refreshPage),
      ),
    );
  }

  @override
  void dispose() {
    try {
      // Dispose of the PagingController when the state object is disposed
      _pagingController.dispose();
    } catch (e) {
      commonLogger.e("An error has occured: $e");
    }
    super.dispose();
  }
}
