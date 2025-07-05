import "package:flutter/material.dart";
import "package:infinite_scroll_pagination/infinite_scroll_pagination.dart";
import "package:patinka/social_media/utils/components/list_view/paging_controller.dart";
import "package:patinka/swatch.dart";
import "package:photo_gallery/photo_gallery.dart";
import "package:transparent_image/transparent_image.dart";

class PhotosGridView extends StatefulWidget {
  const PhotosGridView({required this.albums, required this.update, super.key});
  final List<Album>? albums; // A nullable list of Album objects.
  final ValueChanged<String> update;

  @override
  State<PhotosGridView> createState() => _PhotosGridViewState();
}

class _PhotosGridViewState extends State<PhotosGridView> {
  // Define method for getPage to run every time a new page needs to be fetched
  Future<List<Medium>?> _getNextPage(
      final int newKey, final int pageSize) async {
    final newItems = (await widget.albums![0].listMedia(
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
