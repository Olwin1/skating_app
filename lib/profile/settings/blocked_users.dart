import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:patinka/api/config.dart";
import "package:patinka/api/support.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/profile/settings/blocked_user_list_widget.dart";
import "package:patinka/social_media/utils/components/list_view/default_item_list.dart";
import "package:patinka/social_media/utils/components/list_view/paging_controller.dart";
import "package:patinka/social_media/utils/pair.dart";
import "package:patinka/swatch.dart";

class BlockedUsersList extends StatefulWidget {
  const BlockedUsersList({super.key});

  @override
  State<BlockedUsersList> createState() => _BlockedUsersListState();
}

class _BlockedUsersListState extends State<BlockedUsersList> {
  // The controller that manages pagination
  final GenericPagingController<Map<String, dynamic>> genericPagingController =
      GenericPagingController(key: const Key("connectionsList"));

  Future<List<Map<String, dynamic>>?> getPage(final int pageKey) async {
    // Fetch the page of comments using the getComments() function
    commonLogger.d("friends selected");
    return await SupportAPI.getBlockedUsers(pageKey);
  }

  @override
  void initState() {
    genericPagingController.initialize(getPage);
    super.initState();
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
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
      body: DefaultItemList(
        pagingController: genericPagingController.pagingController,
        itemBuilder: (final context, final item, final index) =>
            BlockedUserListWidget(
                user: item,
                refreshPage: genericPagingController.pagingController.refresh),
        noItemsFoundMessage: Pair<String>("No Blocked Users", ""),
      ));

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
