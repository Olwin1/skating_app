import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/common_logger.dart';
import 'package:uuid/uuid.dart';
import '../../api/websocket.dart';
import '../../swatch.dart';
import 'list_widget.dart';
import '../../api/messages.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;

// Initialize GetIt for dependency injection
GetIt getIt = GetIt.instance;

class PrivateMessageList extends StatefulWidget {
  // Create HomePage Class
  const PrivateMessageList({Key? key, required this.user, required this.index})
      : super(key: key); // Take 2 arguments optional key and title of post
  final String user; // Define title argument
  final int index; // Define title argument
  @override
  State<PrivateMessageList> createState() =>
      _PrivateMessageList(); //Create state for widget
}

class _PrivateMessageList extends State<PrivateMessageList> {
  String? currentUser;

  @override
  void initState() {
    getUserId().then((value) => mounted
        ? setState(() => currentUser = value ?? const Uuid().v1())
        : null);
    super.initState();
  }

  @override // Override existing build method
  Widget build(BuildContext context) {
    return Scaffold(
        //Create a scaffold
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.channels,
              style: TextStyle(
                color: swatch[700],
              )),
        ), // Add a basic app bar
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: const AssetImage("assets/backgrounds/graffiti.png"),
                fit: BoxFit.cover,
                alignment: Alignment.bottomRight,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5), BlendMode.srcOver)),
          ),
          padding:
              const EdgeInsets.all(0), // Add padding so doesn't touch edges
          child: Column(
            children: [
              Expanded(
                  // Make list view expandable
                  child: currentUser == null
                      ? Container()
                      : ChannelsListView(
                          currentUser: currentUser!,
                        )),
            ],
          ),
        ));
  }
}

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
              margin: const EdgeInsets.symmetric(
                  horizontal: 8), // Add padding so doesn't touch edges
              padding: const EdgeInsets.symmetric(
                  vertical: 8), // Add padding so doesn't touch edges
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                // Add List image to one row and buttons to another
                CircleAvatar(
                  // Create a circular avatar icon
                  radius: 36, // Set radius to 36
                  backgroundColor: swatch[900]!,
                ),
                // If there is cached user information and an avatar image, use the cached image
                const Padding(
                    padding: EdgeInsets.only(
                        left: 16)), // Space between avatar and text
                Flexible(
                  flex: 6,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Create a column aligned to the left
                        const Padding(
                          //Add padding to the top to move the text down a bit
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
                        ), // Last message sent from user
                      ]),
                ),
              ]))));
  return SizedBox(
      height: 30,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          child,
          child,
          child,
          child,
          child,
          child,
          child,
          child,
          child
        ],
      ));
}

class ChannelsListView extends StatefulWidget {
  const ChannelsListView({super.key, required this.currentUser});
  final String currentUser;

  @override
  State<ChannelsListView> createState() => _ChannelsListViewState();
}

class _ChannelsListViewState extends State<ChannelsListView> {
  static const _pageSize = 20; // Number of items to load in a single page
  List<String> title = [];
  List<String> channel = [];
  late StreamSubscription subscription;
  Map<String, dynamic> channelsData = <String, dynamic>{};

  // PagingController manages the loading of pages as the user scrolls
  final PagingController<int, Map<String, dynamic>> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    // addPageRequestListener is called whenever the user scrolls near the end of the list
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    if (getIt<WebSocketConnection>().socket.disconnected) {
      getIt<WebSocketConnection>()
          .socket
          .connect(); // Connect to socket when user enters messaging pages
    }

    // Subscribe to the websocket stream
    subscription = getIt<WebSocketConnection>().stream.listen((data) => mounted
        ? setState(() {
            channelsData[data["channel"]] = data["content"];
          })
        : null);

    super.initState();
  }

// Fetches the data for the given pageKey and appends it to the list of items
  Future<void> _fetchPage(int pageKey) async {
    try {
// Loads the next page of channels
      final page = await getChannels(
        pageKey,
      );
// Create an empty list to hold new channel items
      var newChannels = [];

// Loop through each item on the page
      for (int i = 0; i < page.length; i++) {
        Map<String, dynamic> item = page[i];

        // Extract the participant name and add it to the 'title' list
        title.add(item['participants'][0]);

        // Extract the channel ID and add it to the 'channel' list
        channel.add(item['_id']);

        // Add the channel ID to the 'newChannels' list
        newChannels.add(item['_id']);

        // Add the channel ID and its creation date to the 'channelsData' map
        channelsData.addAll({item["_id"]: item["creation_date"]});
      }

// Join the newly loaded channels using websockets
      getIt<WebSocketConnection>()
          .socket
          .emit("joinChannel", newChannels.toString());

// Determine if the loaded page is the last page
      final isLastPage = page.length < _pageSize;
      if (!mounted) return;
// If the page is the last page, append it using appendLastPage method
      if (isLastPage) {
        _pagingController.appendLastPage(page);
      }
// If the page is not the last page, append it using appendPage method
      else {
        // Calculate the next page key
        final nextPageKey = pageKey += 1;
        _pagingController.appendPage(page, nextPageKey);
      }
    }
// Handle any errors that occur during loading
    catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) =>
      PagedListView<int, Map<String, dynamic>>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
          noItemsFoundIndicatorBuilder: (context) => Center(
              child: Column(children: [
            Text(
              AppLocalizations.of(context)!.noMessagesFound,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: swatch[701]),
            ),
            Text(
              AppLocalizations.of(context)!.makeFriends,
              style: TextStyle(fontSize: 20, color: swatch[601]),
            ),
          ])),
          firstPageProgressIndicatorBuilder: (context) => _loadingSkeleton(),

          itemBuilder: (context, item, index) => ListWidget(
              userId: title[index],
              index: index,
              channel: channel[index],
              desc:
                  "Last Message: ${timeago.format(DateTime.parse(channelsData[item['_id']]))}",
              currentUser: widget.currentUser), //item id
        ),
      );

  @override
  void dispose() {
    try {
      // Disposes of the PagingController to free up resources
      _pagingController.dispose();
      subscription.cancel(); // Stop listening to new messages
      if (getIt<WebSocketConnection>().socket.connected) {
        getIt<WebSocketConnection>()
            .socket
            .disconnect(); // Disconnect from websocket when user leaves messaging pages
      }
    } catch (e) {
      commonLogger.e("An error has occured: $e");
    }
    super.dispose();
  }
}
