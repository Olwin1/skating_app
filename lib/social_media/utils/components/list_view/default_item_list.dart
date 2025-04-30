import "package:flutter/material.dart";
import "package:infinite_scroll_pagination/infinite_scroll_pagination.dart";
import "package:patinka/components/list_error.dart";
import "package:patinka/social_media/utils/components/list_view/paging_controller.dart";
import "package:patinka/social_media/utils/pair.dart";

/// A generic paginated list view that supports dynamic item rendering.
///
/// This widget utilizes a `PagedListView` to handle pagination and display
/// items dynamically. It requires a `PagingController` to manage pagination
/// and an `itemBuilder` function to render each item.
///
/// Example usage:
/// ```dart
/// DefaultItemList(
///   pagingController: myPagingController,
///   itemBuilder: (context, item, index) => MyItemWidget(item),
///   noItemsFoundMessage: Pair<String>("No Items", "Try reloading the list."),
/// )
/// ```
class DefaultItemList extends StatelessWidget {
  /// Creates a `DefaultItemList` widget.
  ///
  /// Requires a `pagingController` to manage paginated data and an `itemBuilder`
  /// to render list items. Optionally, a `firstPageProgressIndicatorBuilder`
  /// can be provided to customize the loading indicator.
  const DefaultItemList({
    required this.genericStateController,
    required this.itemBuilder,
    required this.noItemsFoundMessage,
    this.firstPageProgressIndicatorBuilder,
    super.key,
  });

  /// Controller responsible for handling pagination logic.
  final GenericStateController<Map<String, dynamic>> genericStateController;

  /// Callback function used to build each item in the list.
  final Widget Function(BuildContext, Map<String, dynamic>, int) itemBuilder;

  /// Message displayed when no items are found.
  final Pair<String> noItemsFoundMessage;

  /// Optional builder for the first-page progress indicator.
  final Widget Function(BuildContext)? firstPageProgressIndicatorBuilder;

  @override
  Widget build(final BuildContext context) =>
      PagedListView<int, Map<String, dynamic>>(
        state: genericStateController.pagingState,
        fetchNextPage: genericStateController.getNextPage,
        builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
          // Builds each item in the list using the provided `itemBuilder`.
          itemBuilder: itemBuilder,

          // Displays a custom error message when no items are found.
          noItemsFoundIndicatorBuilder: (final context) =>
              ListError(message: noItemsFoundMessage),

          // Displays a loading indicator while the first page is being fetched.
          firstPageProgressIndicatorBuilder: firstPageProgressIndicatorBuilder,
        ),
      );
}
