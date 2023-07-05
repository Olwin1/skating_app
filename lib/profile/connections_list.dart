import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:skating_app/api/social.dart';
import 'package:skating_app/profile/user_list_widget.dart';

class ConnectionsListView extends StatefulWidget {
  final String type;

  const ConnectionsListView({super.key, required this.type});

  @override
  State<ConnectionsListView> createState() => _ConnectionsListViewState();
}

class _ConnectionsListViewState extends State<ConnectionsListView> {
  // Number of items per page
  static const _pageSize = 20;

  // The controller that manages pagination
  final PagingController<int, Map<String, dynamic>> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    // Add a listener for page requests, and call _fetchPage() when a page is requested
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      List<Map<String, dynamic>> page;
      // Fetch the page of comments using the getComments() function
      print("selecting? ${widget.type}");
      if (widget.type == "followers") {
        print("followers");
        page = await getUserFollowers(
          pageKey,
        );
      }
      if (widget.type == "following") {
        print("following");
        page = await getUserFollowing(
          pageKey,
        );
      }
      if (widget.type == "friends") {
        print("friends");
        page = await getUserFriends(
          pageKey,
        );
      } else {
        page = [];
      }
      // Determine if this is the last page
      final isLastPage = page.length < _pageSize;
      if (!mounted) return;
      if (isLastPage) {
        // If this is the last page, append it to the list of pages
        _pagingController.appendLastPage(page);
      } else {
        // If this is not the last page, append it to the list of pages and request the next page
        final nextPageKey = pageKey += 1;
        _pagingController.appendPage(page, nextPageKey);
      }
    } catch (error) {
      // If there's an error fetching the page, set the error on the controller
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build a paginated list view of comments using the PagedListView widget
    return PagedListView<int, Map<String, dynamic>>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
        // Use the Comment widget to build each item in the list view
        itemBuilder: (context, item, index) => UserListWidget(id: item["user"]),
      ),
    );
  }

  @override
  void dispose() {
    try {
      // Dispose the controller when the widget is disposed
      _pagingController.dispose();
    } catch (e) {
      print(e);
    }
    super.dispose();
  }
}
