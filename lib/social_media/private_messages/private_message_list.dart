// Import necessary packages and files
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:patinka/misc/navbar_provider.dart';
import 'package:patinka/social_media/private_messages/new_channel.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/common_logger.dart';
import 'package:uuid/uuid.dart';
import '../../api/config.dart';
import '../../api/websocket.dart';
import '../../components/list_error.dart';
import '../../swatch.dart';
import 'list_widget.dart';
import '../../api/messages.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'session_notification.dart';

// Initialize GetIt for dependency injection
GetIt getIt = GetIt.instance;

// Define the main widget class
class PrivateMessageList extends StatefulWidget {
  const PrivateMessageList({
    super.key,
    required this.user,
    required this.index,
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
      (value) => mounted
          ? setState(() => currentUser = value ?? const Uuid().v1())
          : null,
    );
    super.initState();
  }

  // Create a paging controller for infinite scrolling
  final PagingController<int, Map<String, dynamic>> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  Widget build(BuildContext context) {
    // Hide the bottom navigation bar
    Provider.of<BottomBarVisibilityProvider>(context, listen: false).hide();

    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) {
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
              onPressed: () => showNotification(context),
              // Navigator.of(context, rootNavigator: false).push(
              //   // Navigate to the new channel page
              //   PageRouteBuilder(
              //     pageBuilder: (context, animation, secondaryAnimation) =>
              //         NewChannelPage(
              //       callback: _pagingController.refresh,
              //     ),
              //     opaque: false,
              //     transitionsBuilder:
              //         (context, animation, secondaryAnimation, child) {
              //       const begin = 0.0;
              //       const end = 1.0;
              //       var tween = Tween(begin: begin, end: end);
              //       var fadeAnimation = tween.animate(animation);
              //       return FadeTransition(
              //         opacity: fadeAnimation,
              //         child: child,
              //       );
              //     },
              //   ),
              // ),
              icon: const Icon(Icons.add),
            )
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0x57000000),
          ),
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              Expanded(
                child: currentUser == null
                    ? Container()
                    : ChannelsListView(
                        currentUser: currentUser!,
                        pagingController: _pagingController,
                        refreshList: _pagingController.refresh),
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
  Widget child = Shimmer.fromColors(
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
      children: List.generate(9, (index) => child),
    ),
  );
}

// Widget for the list of channels
class ChannelsListView extends StatefulWidget {
  const ChannelsListView(
      {super.key,
      required this.currentUser,
      required this.pagingController,
      required this.refreshList});

  final String currentUser;
  final PagingController<int, Map<String, dynamic>> pagingController;
  final VoidCallback refreshList;

  @override
  State<ChannelsListView> createState() => _ChannelsListViewState();
}

// State class for ChannelsListView
class _ChannelsListViewState extends State<ChannelsListView> {
  static const _pageSize = 20;
  List<String> title = [];
  List<String> channel = [];
  late StreamSubscription subscription;
  Map<String, dynamic> channelsData = <String, dynamic>{};
  PagingController<int, Map<String, dynamic>>? _pagingController;

  @override
  void initState() {
    _pagingController = widget.pagingController;
    _pagingController?.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    if (getIt<WebSocketConnection>().socket.disconnected) {
      getIt<WebSocketConnection>().socket.connect();
    }

    subscription = getIt<WebSocketConnection>().stream.listen((data) {mounted
        ? setState(() {
            channelsData[data["channel"]] = data["content"];
          })
        : null; 
      showNotification(context);
        });

    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      commonLogger.d("Fwtching Page");
      final page = await MessagesAPI.getChannels(
        pageKey,
      );

      var newChannels = [];

      for (int i = 0; i < page.length; i++) {
        Map<String, dynamic> item = page[i];
        title.add(item['channel_id']);
        channel.add(item['channel_id']);
        newChannels.add(item['channel_id']);
        channelsData.addAll({item["channel_id"]: item["creation_date"]});
      }

      getIt<WebSocketConnection>()
          .socket
          .emit("joinChannel", newChannels.toString());

      final isLastPage = page.length < _pageSize;
      if (!mounted) return;

      if (isLastPage) {
        if ((_pagingController == null ||
                _pagingController!.itemList == null ||
                _pagingController!.itemList!.isEmpty) &&
            page.isEmpty) {
          _pagingController?.appendLastPage(page);
        } else {
          _pagingController?.appendLastPage([
            ...page,
            {"last": true}
          ]);
        }
      } else {
        final nextPageKey = pageKey += 1;
        _pagingController?.appendPage(page, nextPageKey);
      }
    } catch (error) {
      _pagingController?.error = error;
    }
  }

  @override
  Widget build(BuildContext context) => _pagingController != null
      ? PagedListView<int, Map<String, dynamic>>(
          pagingController: _pagingController!,
          builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
            noItemsFoundIndicatorBuilder: (context) => ListError(
              title: AppLocalizations.of(context)!.noMessagesFound,
              body: AppLocalizations.of(context)!.makeFriends,
            ),
            firstPageProgressIndicatorBuilder: (context) => _loadingSkeleton(),
            itemBuilder: (context, item, index) => item["last"] == true
                ? const SizedBox(
                    height: 72,
                  )
                : ListWidget(
                    index: index,
                    channel: item,
                    desc:
                        "Last Message:", //${timeago.format(DateTime.parse(channelsData[item['channel_id']]))}",
                    currentUser: widget.currentUser,
                    refreshPage: widget.refreshList),
          ),
        )
      : const SizedBox.shrink();

  @override
  void dispose() {
    try {
      _pagingController?.dispose();
      subscription.cancel();
      if (getIt<WebSocketConnection>().socket.connected) {
        getIt<WebSocketConnection>().socket.disconnect();
      }
    } catch (e) {
      commonLogger.e("An error has occurred: $e");
    }
    super.dispose();
  }
}
