import "package:flutter/material.dart";
import "package:infinite_scroll_pagination/infinite_scroll_pagination.dart";
import "package:patinka/components/list_error.dart";
import "package:patinka/social_media/utils/pair.dart";

///
/// Provides a generic way of creating a Paginated List view 
///
class DefaultItemList extends StatelessWidget {
  const DefaultItemList(
      {required this.pagingController,
      required this.itemBuilder,
      required this.noItemsFoundMessage,
      this.firstPageProgressIndicatorBuilder,
      super.key});
  final PagingController<int, Map<String, dynamic>> pagingController;
  final Widget Function(BuildContext, Map<String, dynamic>, int) itemBuilder;
  final Pair<String> noItemsFoundMessage;
  final Widget Function(BuildContext)? firstPageProgressIndicatorBuilder;


  @override
  Widget build(final BuildContext context) =>
      PagedListView<int, Map<String, dynamic>>(
        pagingController: pagingController,
        builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
          // Use the Comment widget to build each item in the list view
          itemBuilder: itemBuilder,
          noItemsFoundIndicatorBuilder: (final context) =>
              ListError(message: noItemsFoundMessage),
          firstPageProgressIndicatorBuilder: firstPageProgressIndicatorBuilder,
        ),
      );
}
