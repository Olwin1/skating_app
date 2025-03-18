import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:infinite_scroll_pagination/infinite_scroll_pagination.dart";
import "package:patinka/api/config.dart";
import "package:patinka/api/messages.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/components/list_error.dart";
import "package:patinka/misc/navbar_provider.dart";
import "package:patinka/social_media/private_messages/suggestion_widget.dart";
import "package:patinka/social_media/utils/components/list_view/default_item_list.dart";
import "package:patinka/social_media/utils/pair.dart";
import "package:patinka/swatch.dart";
import "package:provider/provider.dart";

class NewChannelPage extends StatefulWidget {
  const NewChannelPage({required this.callback, super.key});

  final Function callback;

  @override
  State<NewChannelPage> createState() => _NewChannelPageState();
}

class _NewChannelPageState extends State<NewChannelPage> {
  @override
  Widget build(final BuildContext context) {
    // Hide the bottom navigation bar
    Provider.of<BottomBarVisibilityProvider>(context, listen: false).hide();

    // Build the page with a paginated list view
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (final bool didPop, final result) {
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
          padding: EdgeInsets.zero,
          child: NewChannelListView(callback: widget.callback),
        ),
      ),
    );
  }
}

class NewChannelListView extends StatefulWidget {
  const NewChannelListView({required this.callback, super.key});
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
    _pagingController.addPageRequestListener(_fetchPage);
    super.initState();
  }

  Future<void> _fetchPage(final int pageKey) async {
    try {
      // Fetch a page of suggestions from the API
      final List<Map<String, dynamic>> page =
          await MessagesAPI.getSuggestions(pageKey);

      // Determine if this is the last page
      final isLastPage = page.length < _pageSize;

      if (!mounted) {
        return;
      }

      if (isLastPage) {
        // If this is the last page, append it to the list of pages
        _pagingController.appendLastPage(page);
      } else {
        // If this is not the last page, append it to the list of pages and request the next page
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(page, nextPageKey);
      }
    } catch (error) {
      // If there's an error fetching the page, set the error on the controller
      _pagingController.error = error;
    }
  }

  @override
  Widget build(final BuildContext context) => DefaultItemList(
        pagingController: _pagingController,
        itemBuilder: (final context, final item, final index) =>
            SuggestionListWidget(
          user: item,
          callback: widget.callback,
        ),
        noItemsFoundMessage: Pair<String>("No Suggested Channels", ""),
      );

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
