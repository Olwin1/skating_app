import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:patinka/api/config.dart";
import "package:patinka/api/messages.dart";
import "package:patinka/misc/navbar_provider.dart";
import "package:patinka/social_media/private_messages/suggestion_widget.dart";
import "package:patinka/social_media/utils/components/list_view/default_item_list.dart";
import "package:patinka/social_media/utils/components/list_view/paging_controller.dart";
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
  // The controller that manages pagination
  final GenericStateController<Map<String, dynamic>> genericStateController =
      GenericStateController(key: const Key("connectionsList"));

  Future<List<Map<String, dynamic>>?> _getNextPage(
      final int pageKey, final int pageSize) async {
    // Fetch a page of suggestions from the API
    final List<Map<String, dynamic>> page =
        await MessagesAPI.getSuggestions(pageKey);
    return page;
  }

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
  Widget build(final BuildContext context) => DefaultItemList(
        genericStateController: genericStateController,
        itemBuilder: (final context, final item, final index) =>
            SuggestionListWidget(
          user: item,
          callback: widget.callback,
        ),
        noItemsFoundMessage: Pair<String>("No Suggested Channels", ""),
      );
}
