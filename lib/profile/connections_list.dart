import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:patinka/api/social.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/components/list_error.dart';
import 'package:patinka/profile/list_type.dart';
import 'package:patinka/profile/user_list_widget.dart';

class ConnectionsListView extends StatefulWidget {
  final ListType type;
  final Map<String, dynamic>? user;

  const ConnectionsListView({super.key, required this.type, this.user});

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
      commonLogger.d("Selecting ${widget.type}");
      if (widget.type == ListType.followersList) {
        commonLogger.d("followers selected");
        page = await SocialAPI.getUserFollowers(pageKey, widget.user);
      } else if (widget.type == ListType.followingList) {
        commonLogger.d("following selected");
        page = await SocialAPI.getUserFollowing(pageKey, widget.user);
      } else if (widget.type == ListType.friendsList) {
        commonLogger.d("friends selected");
        page = await SocialAPI.getUserFriends(pageKey, widget.user);
      } else {
        commonLogger.d("nothing selected");
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
        itemBuilder: (context, item, index) => UserListWidget(
            user: item,
            listType: widget.type,
            ownerUser: widget.user,
            refreshPage: _pagingController.refresh),
        noItemsFoundIndicatorBuilder: (context) =>
            const ListError(title: "No Follower", body: ""),
      ),
    );
  }

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
