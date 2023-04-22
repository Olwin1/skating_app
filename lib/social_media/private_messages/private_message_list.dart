import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../api/websocket.dart';
import '../../objects/user.dart';
import 'list_widget.dart';
import '../../api/messages.dart';
import 'package:get_it/get_it.dart';

// Initialize GetIt for dependency injection
GetIt getIt = GetIt.instance;

class PrivateMessageList extends StatefulWidget {
  // Create HomePage Class
  const PrivateMessageList({Key? key, required this.user, required this.index})
      : super(key: key); // Take 2 arguments optional key and title of post
  final User user; // Define title argument
  final int index; // Define title argument
  @override
  State<PrivateMessageList> createState() =>
      _PrivateMessageList(); //Create state for widget
}

class _PrivateMessageList extends State<PrivateMessageList> {
  @override // Override existing build method
  Widget build(BuildContext context) {
    return Scaffold(
        //Create a scaffold
        appBar: AppBar(), // Add a basic app bar
        body: Container(
          padding:
              const EdgeInsets.all(0), // Add padding so doesn't touch edges
          color:
              const Color(0xFFFFE306), // For testing to highlight seperations
          child: Column(
            children: const [
              Expanded(
                  // Make list view expandable
                  child:
                      ChannelsListView() /*ListView(
                padding: const EdgeInsets.all(8),
                // Create list view widget
                // Create a row
                children: [
                  const TextField(
                    // Create text inout field
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'search', //Placeholder text
                    ),
                  ),

                  Title(
                      // Private Messages title
                      color: const Color(0xffcfcfcf),
                      child: const Text(
                        "Private Messages",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      )),
                  const ListWidget(index: 1) // Create basic debug widget
                ], // Set child to a list widget
              )*/
                  ),
            ],
          ),
        ));
  }
}

class ChannelsListView extends StatefulWidget {
  const ChannelsListView({super.key});

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

    // Subscribe to the websocket stream
    subscription = getIt<WebSocketConnection>().stream.listen((data) => {
          setState(() {
            channelsData[data["channel"]] = data["content"];
          })
        });

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
          itemBuilder: (context, item, index) => ListWidget(
              title: title[index],
              index: index,
              channel: channel[index],
              desc: channelsData[item["_id"]]), //item id
        ),
      );

  @override
  void dispose() {
    try {
      // Disposes of the PagingController to free up resources
      _pagingController.dispose();
      subscription.cancel(); // Stop listening to new messages
    } catch (e) {
      print(e);
    }
    super.dispose();
  }
}
