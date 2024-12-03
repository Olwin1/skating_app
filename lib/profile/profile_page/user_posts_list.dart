import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:patinka/api/config.dart';
import 'package:patinka/api/social.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/components/list_error.dart';
import 'package:patinka/swatch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';



// Creates a grid tile widget from an image URL
Widget _createGridTileWidget(Map<String, dynamic> post,
    dynamic imageViewerController, Function refreshPage, Function setCurrentImage) {
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
                  'Are you sure you want to delete this post?',
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
                          'Delete',
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
      onTap: () => {setCurrentImage(post["image"]), imageViewerController(post)},
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





class UserPostsList extends StatefulWidget {
  final Map<String, dynamic>? user;
  final Function metadata;
  final Function setCurrentImage;

  final dynamic imageViewerController;
  const UserPostsList(
      {super.key,
      required this.user,
      required this.imageViewerController,
      required this.metadata, required this.setCurrentImage});

  @override
  State<UserPostsList> createState() => _UserPostsListState();
}

class _UserPostsListState extends State<UserPostsList> {
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
      final page =
          await SocialAPI.getUserPosts(widget.user?["user_id"], pageKey);
      widget.metadata(page);

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
    return widget.user != null
        ? PagedGridView<int, Map<String, dynamic>>(
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
              noItemsFoundIndicatorBuilder: (context) => ListError(
                  title: AppLocalizations.of(context)!.noPostsFound, body: ""),
              // Specify how to build each grid tile
              itemBuilder: (context, item, index) => item["last"] == true
                  ? const SizedBox(
                      height: 72,
                    )
                  : _createGridTileWidget(
                      item, widget.imageViewerController, refreshPage, widget.setCurrentImage),
            ),
          )
        : const SizedBox.shrink();
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
