import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_overlay/flutter_overlay.dart";
import "package:infinite_scroll_pagination/infinite_scroll_pagination.dart";
import "package:patinka/api/config/config.dart";
import "package:patinka/api/social.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/components/list_error.dart";
import "package:patinka/social_media/utils/components/list_view/paging_controller.dart";
import "package:patinka/social_media/utils/pair.dart";
import "package:patinka/swatch.dart";
import "package:shimmer/shimmer.dart";

// Variable to store the currently viewed image
String? currentImage;

// Define a new StatelessWidget called SavedPosts
class SavedPosts extends StatelessWidget {
  // Constructor for SavedPosts
  const SavedPosts({super.key});

  // Override the build method of StatelessWidget to return a Consumer widget
  @override
  Widget build(final BuildContext context) {
    // Function to create a dialog widget for image viewing
    GestureDetector dialog() => GestureDetector(
          onTap: () {
            Navigator.pop(context, "close");
          },
          child: currentImage != null
              ? Container(
                  color: const Color(0x55000000),
                  padding: const EdgeInsets.all(4),
                  child: CachedNetworkImage(
                    imageUrl: "${Config.uri}/image/$currentImage",
                    imageBuilder: (final context, final imageProvider) =>
                        Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        );

    // Function to show the overlay with the image dialog
    void show() {
      HiOverlay.show(
        context,
        child: dialog(),
      ).then((final value) {
        commonLogger.t("Received value: $value");
      });
    }

    return Scaffold(
      backgroundColor: const Color(0x77000000),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // App bar styling
        iconTheme: IconThemeData(color: swatch[701]),
        elevation: 8,
        shadowColor: Colors.green.shade900,
        backgroundColor: Config.appbarColour,
        foregroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text("Saved Posts", style: TextStyle(color: swatch[701])),
      ),
      body: SavedPostsList(imageViewerController: show),
    );
  }
}

// Function to create a grid tile widget from an image URL
Widget _createGridTileWidget(
  final Map<String, dynamic> post,
  final dynamic imageViewerController,
  final Function refreshPage,
) =>
    Builder(builder: (final context) {
      // Function to pop the navigator
      void popNavigator() {
        Navigator.of(context).pop();
      }

      return GestureDetector(
        onLongPress: () async {
          // Show confirmation dialog on long press
          await showDialog(
            useRootNavigator: false,
            context: context,
            builder: (final BuildContext context) => AlertDialog(
              backgroundColor: swatch[800],
              title: Text(
                "Are you sure you want to unsave this post?",
                style: TextStyle(color: swatch[701]),
              ),
              content: SizedBox(
                height: 96,
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () async {
                        // Call API to unsave the post
                        await SocialAPI.unsavePost(post["post_id"]);
                        refreshPage();
                        popNavigator();
                      },
                      child: Text(
                        "Unsave",
                        style: TextStyle(color: swatch[901]),
                      ),
                    ),
                    TextButton(
                      onPressed: popNavigator,
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: swatch[901]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        onTap: () => {
          currentImage = post["image"],
          imageViewerController(),
        },
        child: CachedNetworkImage(
          imageUrl: '${Config.uri}/image/thumbnail/${post["image"]}',
          fit: BoxFit.cover,
          imageBuilder: (final context, final imageProvider) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      );
    });

// Class representing the SavedPostsList widget
class SavedPostsList extends StatefulWidget {
  const SavedPostsList({required this.imageViewerController, super.key});
  final dynamic imageViewerController;

  @override
  State<SavedPostsList> createState() => _SavedPostsListState();
}

class _SavedPostsListState extends State<SavedPostsList> {
    // Define method for getPage to run every time a new page needs to be fetched
  Future<List<Map<String, dynamic>>?> _getNextPage(
      final int newKey, final int pageSize) async {
    final newItems = await SocialAPI.getSavedPosts(newKey);
    return newItems;
  }

  // PagingController to manage pagination
  final GenericStateController<Map<String, dynamic>> genericStateController =
      GenericStateController(key: const Key("savedposts"));

  // Function to create loading widgets for the grid
  Widget _createGridLoadingWidgets() {
    final Widget child = Shimmer.fromColors(
      baseColor: shimmer["base"]!,
      highlightColor: shimmer["highlight"]!,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.asset("assets/placeholders/150.png"),
      ),
    );
    return GridView(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        childAspectRatio: 1,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        maxCrossAxisExtent: MediaQuery.of(context).size.width / 3,
      ),
      children: List.generate(12, (final index) => child),
    );
  }

  @override
  void initState() {
    genericStateController.init(
        this,
        (final newState) =>
            setState(() => genericStateController.pagingState = newState),
        _getNextPage,
        (final _) => []);
    super.initState();
  }

  @override
  Widget build(final BuildContext context) =>
      PagedGridView<int, Map<String, dynamic>>(
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        state: genericStateController.pagingState,
        fetchNextPage: genericStateController.getNextPage,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          childAspectRatio: 1,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          maxCrossAxisExtent: MediaQuery.of(context).size.width / 3,
        ),
        builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
          firstPageProgressIndicatorBuilder: (final context) =>
              _createGridLoadingWidgets(),
          noItemsFoundIndicatorBuilder: (final context) =>
              ListError(message: Pair<String>("No Posts Saved", "")),
          // Build each grid tile
          itemBuilder: (final context, final item, final index) =>
              item["last"] == true
                  ? const SizedBox(
                      height: 72,
                    )
                  : _createGridTileWidget(
                      item["posts"],
                      widget.imageViewerController,
                      genericStateController.refresh),
        ),
      );
}
