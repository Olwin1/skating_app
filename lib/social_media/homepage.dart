import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:patinka/api/config.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/social_media/private_messages/private_message_list.dart';
import 'package:patinka/social_media/search_bar.dart';
import '../api/fcm_token.dart';
import '../api/messages.dart';
import '../api/social.dart';
import '../components/list_error.dart';
import '../swatch.dart';
import 'post_widget.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  // Create HomePage Class
  HomePage({super.key});
  final _scrollController = ScrollController();

  @override // Override the existing widget build method
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          elevation: 8,
          shadowColor: Colors.green.shade900,
          backgroundColor: Config.appbarColour,
          foregroundColor: Colors.transparent,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),

          //title: const Text("Home"),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TextButton(
                // Create a basic button

                child: SvgPicture.asset(
                  "assets/icons/patinka.svg",
                  fit: BoxFit.fitHeight,
                  width: 130,
                  alignment: Alignment.centerLeft,
                  colorFilter: const ColorFilter.mode(
                      Color.fromARGB(255, 116, 0, 81), BlendMode.srcIn),
                ), //#FF8360,

                onPressed: () {
                  // When image pressed
                  _scrollController.animateTo(0, //Scroll to top in 500ms
                      duration: const Duration(milliseconds: 500),
                      curve: Curves
                          .fastOutSlowIn); //Start scrolling fast then slow down when near top
                },
              ),
            ),
            const SearchBarr(),
            TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PrivateMessageList(
                              user: "user",
                              index: 1,
                            ))),
                child: Image.asset(
                    "assets/icons/message.png")) // Set Button To Message icon
          ],
        ),
        body: Center(
            child: PostsListView(
          scrollController: _scrollController,
        )));
  }
}

Widget _loadSkeleton() {
  Widget child = Shimmer.fromColors(
      baseColor: shimmer["base"]!,
      highlightColor: shimmer["highlight"]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
            color: const Color(0xcc000000),
            borderRadius: BorderRadius.circular(8)),
        height: 314,
        padding: const EdgeInsets.all(0), // Add padding so doesn't touch edges

        child: Row(
          // Create a row
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Add Post image to one row and buttons to another
            Expanded(flex: 5, child: Container() // Set child to post image
                ),
            Expanded(
              flex: 1, // Make 2x Bigger than sibling
              child: Container(
                  // Make container widget to use BoxDecoration
                  ),
            ),
          ],
        ),
      ));
  return SizedBox(
      height: 30,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),

        padding: const EdgeInsets.all(
            8), // Add padding to list so doesn't overflow to sides of screen
        children: [child, child, child, child],
      ));
}

class PostsListView extends StatefulWidget {
  const PostsListView(
      {super.key, required this.scrollController}); //required this.update});
  //final ValueChanged<String> update;
  final ScrollController scrollController;

  @override
  State<PostsListView> createState() => _PostsListViewState();
}

class _PostsListViewState extends State<PostsListView> {
  // PagingController manages the loading of pages as the user scrolls
  final PagingController<int, Object> _pagingController =
      PagingController(firstPageKey: 0);
  List<String> seenPosts = [];
  Map<String, dynamic>? user;

  @override
  void initState() {
    MessagesAPI.getUserId().then((userId) {
      if (userId != null) {
        SocialAPI.getUser(userId).then((userA) {
          user = userA;
        });
      }
    });
    FirebaseMessaging.instance
        .getToken()
        .then((fcmToken) => fcmToken != null ? updateToken(fcmToken) : null);

    // addPageRequestListener is called whenever the user scrolls near the end of the list
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

// Fetches the data for the given pageKey and appends it to the list of items
  Future<void> _fetchPage(int pageKey) async {
    try {
      commonLogger.t("Fetching page");
      // Loads the next page of images from the first album, skipping `pageKey` items and taking `_pageSize` items.
      final page = await SocialAPI.getPosts(pageKey);
      // _pagingController.refresh();

      // Loops through each item in the page and adds its ID to the `seenPosts` list
      for (int i = 0; i < page.length; i++) {
        Map<String, dynamic> item = page[i];
        seenPosts.add(item['post_id']);
        commonLogger.d("Seen posts: $seenPosts");
      }

      // Determines if the page being fetched is the last page
      final isLastPage = page.isEmpty;
      if (!mounted) return;
      if (isLastPage) {
        // If the page is the last page, call `appendLastPage` to add it to the list of items
        if ((_pagingController.itemList == null ||
                _pagingController.itemList!.isEmpty) &&
            page.isEmpty) {
          _pagingController.appendLastPage(page);
        } else {
          _pagingController.appendLastPage([
            ...page,
            {"last": true}
          ]);
        }
      } else {
        final nextPageKey = pageKey += 1;
        // If the page is not the last page, call `appendPage` to add the newly loaded items to the list of items
        _pagingController.appendPage(page, nextPageKey);
      }
    } catch (error) {
      // If an error occurs, sets the error state of the PagingController
      _pagingController.error = error;
    }
  }

  Future<void> refreshPage() async {
    seenPosts = [];
    _pagingController.refresh();
    // _pagingController.addPageRequestListener((pageKey) {
    //   _fetchPage(pageKey);
    // });
    //_fetchPage(0);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double size = height >= width ? width : height;
    if (size > 1080) {
      commonLogger.i("larger than 1080");
      size = 1080;
    }
    commonLogger.i("resif");
    return Stack(children: [
      RefreshIndicator(
        edgeOffset: 94,
        onRefresh: () => refreshPage(),
        child: PagedListView<int, Object>(
          cacheExtent: 1024,
          pagingController: _pagingController,
          scrollController: widget.scrollController,
          // builderDelegate is responsible for creating the actual widgets to be displayed
          builderDelegate: PagedChildBuilderDelegate<Object>(
              firstPageProgressIndicatorBuilder: (context) => _loadSkeleton(),
              noItemsFoundIndicatorBuilder: (context) => ListError(
                  title: AppLocalizations.of(context)!.noPostsFound,
                  body: AppLocalizations.of(context)!.makeFriends),
              // itemBuilder is called for each item in the list to create a widget for that item
              itemBuilder: (context, dynamic item, index) =>
                  item["last"] == true
                      ? const SizedBox(
                          height: 72,
                        )
                      : index == 0
                          ? Padding(
                              padding: const EdgeInsets.only(top: 106),
                              child: SizedBox(
                                  width: size,
                                  height: size,
                                  child: PostWidget(
                                      post: item, index: index, user: user)))
                          : SizedBox(
                              width: size,
                              height: size,
                              child: PostWidget(
                                  post: item, index: index, user: user))),
          padding: const EdgeInsets.all(
              8), // Add padding to list so doesn't overflow to sides of screen
        ),
      )
    ]);
  }

  @override
  void dispose() {
    // Disposes of the PagingController to free up resources
    _pagingController.dispose();
    super.dispose();
  }
}


/*
Nearby skateparks
gen areas
scout hut opposite



*/