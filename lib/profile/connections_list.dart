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
  // Define method for getPage to run every time a new page needs to be fetched
  Future<List<Map<String, dynamic>>?> _getNextPage(
      final int newKey, final int pageSize) async {
    List<Map<String, dynamic>>? page;
    // Fetch the page of comments using the getComments() function
    commonLogger.d("Selecting ${widget.type}");
    if (widget.type == ListType.followersList) {
      commonLogger.d("followers selected");
      page = await SocialAPI.getUserFollowers(newKey, widget.user);
    } else if (widget.type == ListType.followingList) {
      commonLogger.d("following selected");
      page = await SocialAPI.getUserFollowing(newKey, widget.user);
    } else if (widget.type == ListType.friendsList) {
      commonLogger.d("friends selected");
      page = await SocialAPI.getUserFriends(newKey, widget.user);
    } else {
      commonLogger.d("nothing selected");
      page = [];
    }
    return page;
  }

  final GenericStateController<Map<String, dynamic>> genericStateController =
      GenericStateController(key: const Key("connectionsList"));

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
      // Create a Paged List View
      DefaultItemList(
        genericStateController: genericStateController,
        itemBuilder: (final context, final item, final index) => UserListWidget(
            user: item,
            listType: widget.type,
            ownerUser: widget.user,
            refreshPage: genericStateController.refresh),
        noItemsFoundMessage: Pair<String>("No Followers", ""),
      );
}
