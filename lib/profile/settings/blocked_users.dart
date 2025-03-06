import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:infinite_scroll_pagination/infinite_scroll_pagination.dart";
import "package:patinka/api/config.dart";
import "package:patinka/api/support.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/components/list_error.dart";
import "package:patinka/profile/settings/blocked_user_list_widget.dart";
import "package:patinka/swatch.dart";

class BlockedUsersList extends StatefulWidget {
  const BlockedUsersList({super.key});

  @override
  State<BlockedUsersList> createState() => _BlockedUsersListState();
}

class _BlockedUsersListState extends State<BlockedUsersList> {
  // Number of items per page
  static const _pageSize = 20;

  // The controller that manages pagination
  final PagingController<int, Map<String, dynamic>> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    // Add a listener for page requests, and call _fetchPage() when a page is requested
    _pagingController.addPageRequestListener(_fetchPage);
    super.initState();
  }

  Future<void> _fetchPage(final int pageKey) async {
    try {
      List<Map<String, dynamic>> page;
      // Fetch the page of comments using the getComments() function
      commonLogger.d("friends selected");
      page = await SupportAPI.getBlockedUsers(pageKey);

      // Determine if this is the last page
      final isLastPage = page.length < _pageSize;
      if (!mounted) {
        return;
      }
      if (isLastPage) {
        // If this is the last page, append it to the list of pages
        _pagingController.appendLastPage(page);
      } else {
        // If this is not the last page, append it to the list of pages and request the next page
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(page, nextPageKey);
      }
    } catch (error) {
      // If there's an error fetching the page, set the error on the controller
      _pagingController.error = error;
    }
  }

  @override
  Widget build(final BuildContext context) =>
      Scaffold(
        backgroundColor: const Color(0x34000000),
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        extendBody: true,
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
              "Blocked Users",
              style: TextStyle(color: swatch[701]),
            )),
        body: PagedListView<int, Map<String, dynamic>>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
          // Use the Comment widget to build each item in the list view
          itemBuilder: (final context, final item, final index) =>
              BlockedUserListWidget(
                  user: item,
                  refreshPage: _pagingController.refresh),
          noItemsFoundIndicatorBuilder: (final context) =>
              const ListError(title: "No Blocked Users", body: ""),
        ),
      ));

  @override
  void dispose() {
    try {
      // Dispose the controller when the widget is disposed
      _pagingController.dispose();
    } catch (e) {
      commonLogger.e("Error in dispose: $e");
    }
    super.dispose();
  }
}
