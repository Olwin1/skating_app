import "package:flutter/material.dart";
import "package:patinka/api/social.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/profile/list_type.dart";
import "package:patinka/profile/user_list_widget.dart";
import "package:patinka/social_media/utils/components/list_view/default_item_list.dart";
import "package:patinka/social_media/utils/components/list_view/paging_controller.dart";
import "package:patinka/social_media/utils/pair.dart";

class ConnectionsListView extends StatefulWidget {
  const ConnectionsListView({required this.type, super.key, this.user});
  final ListType type;
  final Map<String, dynamic>? user;

  @override
  State<ConnectionsListView> createState() => _ConnectionsListViewState();
}

class _ConnectionsListViewState extends State<ConnectionsListView> {
  // The controller that manages pagination
  Future<List<Map<String, dynamic>>?> getPage(final int pageKey) async {
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
      if(!mounted) {
        return null;
      }
      return page;
  }
    final GenericPagingController<Map<String, dynamic>> genericPagingController = GenericPagingController(key: const Key("connectionsList"));

  @override
  void initState() {
    genericPagingController.initialize(getPage, null);
    super.initState();
  }

  @override
  Widget build(final BuildContext context) =>
      // Create a Paged List View
      DefaultItemList(
        pagingController: genericPagingController.pagingController,
        itemBuilder: (final context, final item, final index) => UserListWidget(
            user: item,
            listType: widget.type,
            ownerUser: widget.user,
            refreshPage: genericPagingController.pagingController.refresh),
        noItemsFoundMessage: Pair<String>("No Followers", ""),
      );

  @override
  void dispose() {
    try {
      // Dispose the controller when the widget is disposed
      genericPagingController.pagingController.dispose();
    } catch (e) {
      commonLogger.e("Error in dispose: $e");
    }
    super.dispose();
  }
}
