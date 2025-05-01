import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:infinite_scroll_pagination/infinite_scroll_pagination.dart";
import "package:patinka/api/config.dart";
import "package:patinka/api/social.dart";
import "package:patinka/components/list_error.dart";
import "package:patinka/social_media/utils/components/list_view/paging_controller.dart";
import "package:patinka/social_media/utils/pair.dart";
import "package:patinka/swatch.dart";
import "package:shimmer/shimmer.dart";

// Creates a grid tile widget from an image URL
Widget _createGridTileWidget(
        final Map<String, dynamic> post,
        final dynamic imageViewerController,
        final Function refreshPage,
        final Function setCurrentImage) =>
    Builder(builder: (final context) {
      void popNavigator() {
        Navigator.of(context).pop();
      }

      return GestureDetector(
        onLongPress: () async {
          await showDialog(
            useRootNavigator: false,
            context: context,
            builder: (final BuildContext context) => AlertDialog(
                backgroundColor: swatch[800],
                title: Text(
                  "Are you sure you want to delete this post?",
                  style: TextStyle(color: swatch[701]),
                ),
                content: SizedBox(
                    height: 96,
                    child: Column(children: [
                      TextButton(
                        onPressed: () async {
                          await SocialAPI.delPost(post["post_id"]);
                          refreshPage();
                          popNavigator();
                        },
                        child: Text(
                          "Delete",
                          style: TextStyle(color: swatch[901]),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          popNavigator();
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: swatch[901]),
                        ),
                      )
                    ]))),
          );
        },
        //onLongPressEnd: (details) => _popupDialog?.remove(),
        onTap: () =>
            {setCurrentImage(post["image"]), imageViewerController(post)},
        child: CachedNetworkImage(
          imageUrl: '${Config.uri}/image/thumbnail/${post["image"]}',
          fit: BoxFit.cover,
          imageBuilder: (final context, final imageProvider) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  8), // Set the shape of the container to a circle
              image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
            ),
          ),
        ), // Display the image from the URL
      );
    });

class UserPostsList extends StatefulWidget {
  const UserPostsList(
      {required this.user,
      required this.imageViewerController,
      required this.metadata,
      required this.setCurrentImage,
      super.key});
  final Map<String, dynamic>? user;
  final Function metadata;
  final Function setCurrentImage;

  final dynamic imageViewerController;

  @override
  State<UserPostsList> createState() => _UserPostsListState();
}

class _UserPostsListState extends State<UserPostsList> {
    // Define method for getPage to run every time a new page needs to be fetched
  Future<List<Map<String, dynamic>>> _getNextPage(
      final int newKey, final int pageSize) async {

    // Fetch the next page of posts from the user's account
    final page = await SocialAPI.getUserPosts(widget.user?["user_id"], newKey);
    widget.metadata(page);
    return page;
  }

  // Create a PagingController to manage pagination
  final GenericStateController<Map<String, dynamic>> genericStateController =
      GenericStateController(key: const Key("userPostsList"));

  Widget _createGridLoadingWidgets() {
    final Widget child = Shimmer.fromColors(
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

  List<Map<String, dynamic>> _handleLastPage(
      final List<Map<String, dynamic>> pages) {

      final int rem = 4 -
          (pages.length) %
              3;
      final List<Map<String, dynamic>> spacers = [];
      for (int i = 0; i < rem; i++) {
        spacers.add({"last": true});
      }
      return spacers;
  }

  @override
  void initState() {
    // Initialise the paging controller
    genericStateController.init(
        this,
        (final newState) =>
            setState(() => genericStateController.pagingState = newState),
        _getNextPage,
        _handleLastPage);
    super.initState();
  }

  @override
  Widget build(final BuildContext context) => widget.user != null
      ? PagedGridView<int, Map<String, dynamic>>(
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          state: genericStateController.pagingState,
          fetchNextPage: genericStateController.getNextPage,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            // Specify the properties for the grid tiles
            childAspectRatio: 1,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            maxCrossAxisExtent: MediaQuery.of(context).size.width / 3,
          ),
          builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
            firstPageProgressIndicatorBuilder: (final context) =>
                _createGridLoadingWidgets(),
            noItemsFoundIndicatorBuilder: (final context) => ListError(
                message: Pair<String>(
                    AppLocalizations.of(context)!.noPostsFound, "")),
            // Specify how to build each grid tile
            itemBuilder: (final context, final item, final index) =>
                item["last"] == true
                    ? const SizedBox(
                        height: 72,
                      )
                    : _createGridTileWidget(
                        item,
                        widget.imageViewerController,
                        genericStateController.refresh,
                        widget.setCurrentImage),
          ),
        )
      : const SizedBox.shrink();

}
