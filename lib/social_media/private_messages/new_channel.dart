import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:patinka/api/messages.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/misc/navbar_provider.dart';
import 'package:patinka/social_media/private_messages/suggestion_widget.dart';
import 'package:provider/provider.dart';
import '../../api/config.dart';
import '../../components/list_error.dart';
import '../../swatch.dart';

class NewChannelPage extends StatefulWidget {
  const NewChannelPage({super.key, required this.callback});

  final Function callback;

  @override
  State<NewChannelPage> createState() => _NewChannelPageState();
}

class _NewChannelPageState extends State<NewChannelPage> {
  @override
  Widget build(BuildContext context) {
    // Hide the bottom navigation bar
    Provider.of<BottomBarVisibilityProvider>(context, listen: false).hide();

    // Build the page with a paginated list view
    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          // Show the bottom navigation bar when popping
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
          elevation: 0,
          shadowColor: Colors.green.shade900,
          backgroundColor: Config.appbarColour,
          foregroundColor: Colors.transparent,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          title: Text(
            "Compose Message",
            style: TextStyle(color: swatch[701]),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(color: Color(0x38000000)),
          padding: const EdgeInsets.all(0),
          child: NewChannelListView(callback: widget.callback),
        ),
      ),
    );
  }
}

class NewChannelListView extends StatefulWidget {
  const NewChannelListView({super.key, required this.callback});
  final Function callback;

  @override
  State<NewChannelListView> createState() => _NewChannelListViewState();
}

class _NewChannelListViewState extends State<NewChannelListView> {
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
      // Fetch a page of suggestions from the API
      List<Map<String, dynamic>> page =
          await MessagesAPI.getSuggestions(pageKey);

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
    // Build a paginated list view of suggestions using the PagedListView widget
    return PagedListView<int, Map<String, dynamic>>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
        // Use the SuggestionListWidget to build each item in the list view
        itemBuilder: (context, item, index) => SuggestionListWidget(
          user: item,
          callback: widget.callback,
        ),
        // Display an error message when there are no suggested messages
        noItemsFoundIndicatorBuilder: (context) => const ListError(
          title: "No suggested messages",
          body: "",
        ),
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
