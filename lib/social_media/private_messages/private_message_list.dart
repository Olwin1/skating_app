// Import necessary packages and files
import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:get_it/get_it.dart";
import "package:patinka/api/config.dart";
import "package:patinka/api/messages.dart";
import "package:patinka/api/websocket.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/misc/navbar_provider.dart";
import "package:patinka/social_media/private_messages/list_widget.dart";
import "package:patinka/social_media/private_messages/new_channel.dart";
import "package:patinka/misc/notifications/session_notification.dart";
import "package:patinka/social_media/utils/components/list_view/default_item_list.dart";
import "package:patinka/social_media/utils/components/list_view/paging_controller.dart";
import "package:patinka/social_media/utils/current_channel.dart";
import "package:patinka/social_media/utils/pair.dart";
import "package:patinka/swatch.dart";
import "package:provider/provider.dart";
import "package:shimmer/shimmer.dart";
import "package:uuid/uuid.dart";

// Initialize GetIt for dependency injection
GetIt getIt = GetIt.instance;

// Define the main widget class
class PrivateMessageList extends StatefulWidget {
  const PrivateMessageList({
    required this.user,
    required this.index,
    super.key,
  });

  final String user; // User's identifier
  final int index; // Index for the private message list

  @override
  State<PrivateMessageList> createState() => _PrivateMessageList();
}

// Define the state class for PrivateMessageList
class _PrivateMessageList extends State<PrivateMessageList> {
  String? currentUser; // Current user's identifier

  @override
  void initState() {
    // Get the current user's identifier and set the state
    MessagesAPI.getUserId().then(
      (final value) => mounted
          ? setState(() => currentUser = value ?? const Uuid().v1())
          : null,
    );
    super.initState();
  }

  // Create a paging controller for infinite scrolling
  final GenericStateController<Map<String, dynamic>> genericStateController =
      GenericStateController(key: const Key("privateMessageList"));

  @override
  Widget build(final BuildContext context) {
    // Hide the bottom navigation bar
    Provider.of<BottomBarVisibilityProvider>(context, listen: false).hide();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (final bool didPop, final result) {
        // Show the bottom navigation bar when navigating back
        if (didPop) {
          Provider.of<BottomBarVisibilityProvider>(context, listen: false)
              .show();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          iconTheme: IconThemeData(color: swatch[701]),
          elevation: 8,
          backgroundColor: Config.appbarColour,
          foregroundColor: Colors.transparent,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          title: Text(
            AppLocalizations.of(context)!.channels,
            style: TextStyle(
              color: swatch[701],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context, rootNavigator: false).push(
                // Navigate to the new channel page
                PageRouteBuilder(
                  pageBuilder: (final context, final animation,
                          final secondaryAnimation) =>
                      NewChannelPage(
                    callback: genericStateController.refresh,
                  ),
                  opaque: false,
                  transitionsBuilder: (final context, final animation,
                      final secondaryAnimation, final child) {
                    const begin = 0.0;
                    const end = 1.0;
                    final tween = Tween(begin: begin, end: end);
                    final fadeAnimation = tween.animate(animation);
                    return FadeTransition(
                      opacity: fadeAnimation,
                      child: child,
                    );
                  },
                ),
              ),
              icon: const Icon(Icons.add),
            )
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0x57000000),
          ),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Expanded(
                child: currentUser == null
                    ? const SizedBox.shrink()
                    : ChannelsListView(
                        currentUser: currentUser!,
                        genericStateController: genericStateController,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget for the loading skeleton
Widget _loadingSkeleton() {
  final Widget child = Shimmer.fromColors(
    baseColor: shimmer["base"]!,
    highlightColor: shimmer["highlight"]!,
    child: Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xb5000000),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        height: 82,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: swatch[900],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16),
            ),
            Flexible(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                  ),
                  Container(
                    width: 100,
                    height: 24.0,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Container(
                    width: 250,
                    height: 24.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return SizedBox(
    height: 30,
    child: ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(9, (final index) => child),
    ),
  );
}

// Widget for the list of channels
class ChannelsListView extends StatefulWidget {
  const ChannelsListView({
    required this.currentUser,
    required this.genericStateController,
    super.key,
  });

  final String currentUser;
  final GenericStateController<Map<String, dynamic>> genericStateController;

  @override
  State<ChannelsListView> createState() => _ChannelsListViewState();
}

// State class for ChannelsListView
class _ChannelsListViewState extends State<ChannelsListView> {
  List<String> title = [];
  List<String> channel = [];
  late StreamSubscription subscriptionMessages;
  Map<String, dynamic> channelsData = <String, dynamic>{};
  // GenericStateController manages the loading of pages as the user scrolls
  late GenericStateController<Map<String, dynamic>> genericStateController;

  Future<List<Map<String, dynamic>>?> _getNextPage(
      final int pageKey, final int pageSize) async {
    commonLogger.d("Fetching Page");
    final page = await MessagesAPI.getChannels(
      pageKey,
    );

    final List<String> newChannels = [];

    for (int i = 0; i < page.length; i++) {
      final Map<String, dynamic> item = page[i];
      title.add(item["channel_id"]);
      channel.add(item["channel_id"]);
      newChannels.add(item["channel_id"]);
      channelsData.addAll({
        item["channel_id"]: {
          "created_at": item["creation_date"],
          "last_message": item["last_message"]
        }
      });
    }

    getIt<WebSocketConnection>()
        .socket
        .emit("joinChannel", newChannels.toString());
    return page;
  }

// TODO: Add a special handler
  // List<Map<String, dynamic>> handleLastPage(
  //     final List<Map<String, dynamic>> page) {
  //   if ((genericStateController.pagingController.items == null ||
  //           genericStateController.pagingController.items!.isEmpty) &&
  //       page.isEmpty) {
  //     return page;
  //   } else {
  //     return [
  //       ...page,
  //       {"last": true}
  //     ];
  //   }
  // }

  @override
  void initState() {
    genericStateController = widget.genericStateController;
    genericStateController.init(
        this,
        (final newState) =>
            setState(() => genericStateController.pagingState = newState),
        _getNextPage,
        (final _) => []);
    if (getIt<WebSocketConnection>().socket.disconnected) {
      getIt<WebSocketConnection>().socket.connect();
    }

    // Add to stack tracking current pages
    CurrentMessageChannel.instance.pushToStack = "list";

    // Listen for notifications
    subscriptionMessages =
        getIt<WebSocketConnection>().streamMessages.listen((final data) {
      if (!mounted) {
        return; // Prevent updates when the widget is unmounted or not the active page
      }

      setState(() {
        channelsData[data["channel"]] = data["content"];
      });

      showNotification(context, data, widget.currentUser);
    });

    super.initState();
  }

  @override
  Widget build(final BuildContext context) => DefaultItemList(
        genericStateController: genericStateController,
        noItemsFoundMessage: Pair<String>(
            AppLocalizations.of(context)!.noMessagesFound,
            AppLocalizations.of(context)!.makeFriends),
        firstPageProgressIndicatorBuilder: (final context) =>
            _loadingSkeleton(),
        itemBuilder: (final context, final item, final index) => item["last"] ==
                true
            ? const SizedBox(
                height: 72,
              )
            : ListWidget(
                index: index,
                channel: item,
                desc:
                    "Last Message:", //${timeago.format(DateTime.parse(channelsData[item['channel_id']]))}",
                currentUser: widget.currentUser,
                refreshPage: genericStateController.refresh),
      );

      @override
  void dispose() {
    subscriptionMessages.cancel();
    super.dispose();
  }
}
