import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../objects/user.dart';
import 'list_widget.dart';
import '../../api/messages.dart';

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

  // PagingController manages the loading of pages as the user scrolls
  final PagingController<int, Object> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    // addPageRequestListener is called whenever the user scrolls near the end of the list
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  // Fetches the data for the given pageKey and appends it to the list of items
  Future<void> _fetchPage(int pageKey) async {
    try {
      // Loads the next page of images from the first album, skipping `pageKey` items and taking `_pageSize` items.
      final page = await getChannels(
        pageKey,
      );
      for (int i = 0; i < page.length; i++) {
        Map<String, dynamic> item = page[i] as Map<String, dynamic>;
        title.add(item['participants'][0]);
        channel.add(item['_id']);
      }
      final isLastPage = page.length < _pageSize;
      if (isLastPage) {
        // appendLastPage is called if there are no more items to load
        _pagingController.appendLastPage(page);
      } else {
        // appendPage is called to add the newly loaded items to the list of items
        final nextPageKey = pageKey += 1;
        _pagingController.appendPage(page, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) => PagedListView<int, Object>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Object>(
          itemBuilder: (context, item, index) => ListWidget(
              title: title[index],
              index: index,
              channel: channel[index]), //item id
        ),
      );

  @override
  void dispose() {
    // Disposes of the PagingController to free up resources
    _pagingController.dispose();
    super.dispose();
  }
}
