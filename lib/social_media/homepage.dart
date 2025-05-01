import "dart:io";

import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:infinite_scroll_pagination/infinite_scroll_pagination.dart";
import "package:patinka/api/config.dart";
import "package:patinka/api/fcm_token.dart";
import "package:patinka/api/messages.dart";
import "package:patinka/api/social.dart";
import "package:patinka/caching/manager.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/components/list_error.dart";
import "package:patinka/misc/navbar_provider.dart";
import "package:patinka/social_media/post_widget.dart";
import "package:patinka/social_media/private_messages/private_message_list.dart";
import "package:patinka/social_media/search_bar.dart";
import "package:patinka/social_media/utils/components/list_view/paging_controller.dart";
import "package:patinka/social_media/utils/pair.dart";
import "package:patinka/swatch.dart";
import "package:provider/provider.dart";
import "package:shimmer/shimmer.dart";

// HomePage Class
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(final BuildContext context) {
    // FOR DEBUG PURPOSES ONLY
    NetworkManager.instance.deleteAllLocalData();
    //---------------------
    final ScrollController scrollController = ScrollController();

    // Show the Navbar
    Provider.of<BottomBarVisibilityProvider>(context, listen: false).show();

    return Stack(children: [
      Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          // App Bar Configuration
          elevation: 8,
          shadowColor: Colors.green.shade900,
          backgroundColor: Config.appbarColour,
          foregroundColor: Colors.transparent,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          actions: [
            // App Bar Actions
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TextButton(
                onPressed: () {
                  // Scroll to top when image pressed
                  scrollController.animateTo(0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.fastOutSlowIn);
                },
                child: SvgPicture.asset(
                  "assets/icons/patinka.svg",
                  fit: BoxFit.fitHeight,
                  width: 130,
                  alignment: Alignment.centerLeft,
                  colorFilter: const ColorFilter.mode(
                      Color.fromARGB(255, 116, 0, 81), BlendMode.srcIn),
                ),
              ),
            ),
            const SearchBarr(),
            // Navigate to Private Message List
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: "/PrivateMessageList"),
                  builder: (final context) => const PrivateMessageList(
                    user: "user",
                    index: 1,
                  ),
                ),
              ),
              child: Image.asset("assets/icons/message.png"),
            ),
          ],
        ),
        body: Center(
          child: PostsListView(
            scrollController: scrollController,
            key: postsListView,
          ),
        ),
      ),
      const Positioned(
          top: 35,
          left: 45,
          child: Text(
            "This is an Alpha much is non-functional",
            style: TextStyle(color: Colors.amber),
          ))
    ]);
  }
}

Widget _loadSkeleton() {
  final Widget child = Shimmer.fromColors(
      baseColor: shimmer["base"]!,
      highlightColor: shimmer["highlight"]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
            color: const Color(0xcc000000),
            borderRadius: BorderRadius.circular(8)),
        height: 314,
        padding: EdgeInsets.zero, // Add padding so doesn't touch edges

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

final GlobalKey<PostsListViewState> postsListView = GlobalKey();

// Posts List View Widget
class PostsListView extends StatefulWidget {
  const PostsListView({required this.scrollController, super.key});

  final ScrollController scrollController;

  @override
  State<PostsListView> createState() => PostsListViewState();
}

class PostsListViewState extends State<PostsListView> {
  // PagingController manages the loading of pages as the user scrolls
  final GenericStateController<Map<String, dynamic>> genericStateController =
      GenericStateController(key: const Key("homepage"));
  List<String> seenPosts = [];
  Map<String, dynamic>? user;

  Future<List<Map<String, dynamic>>?> _getNextPage(final int pageKey, final int pageSize) async {
    commonLogger.t("Fetching page");
    final page = await SocialAPI.getPosts(pageKey);

    // Loops through each item in the page and adds its ID to the `seenPosts` list
    for (int i = 0; i < page.length; i++) {
      final Map<String, dynamic> item = page[i];
      seenPosts.add(item["post_id"]);
    }
    return page;
  }

// TODO: add a special handler
  // List<Object> handleLastPage(final List<Object> page) {
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
    // Initialize State
    MessagesAPI.getUserId().then((final userId) {
      if (userId != null) {
        SocialAPI.getUser(userId).then((final userA) {
          user = userA;
        });
      }
    });

    // Get FCM Token (excluding Windows and Linux)
    if (!(Platform.isWindows || Platform.isLinux)) {
      FirebaseMessaging.instance.getToken().then(
          (final fcmToken) => fcmToken != null ? updateToken(fcmToken) : null);
    }

    // Initialise paging controller
    genericStateController.init(
        this,
        (final newState) =>
            setState(() => genericStateController.pagingState = newState),
        _getNextPage,
        (final _) => []);

    super.initState();
  }

  // Refresh Page Function
  Future<void> refreshPage() async {
    seenPosts = [];
    await NetworkManager.instance
        .deleteLocalData(name: "posts", type: CacheTypes.list);
    genericStateController.refresh();
  }

  @override
  Widget build(final BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    double size = height >= width ? width : height;
    if (size > 1080) {
      size = 1080;
    }

    return Stack(
      children: [
        RefreshIndicator(
          edgeOffset: 94,
          onRefresh: refreshPage,
          child: PagedListView<int, Object>(
            clipBehavior: Clip.none,
            cacheExtent: 1024,
            state: genericStateController.pagingState,
            fetchNextPage: genericStateController.getNextPage,
            scrollController: widget.scrollController,
            builderDelegate: PagedChildBuilderDelegate<Object>(
              firstPageProgressIndicatorBuilder: (final context) =>
                  _loadSkeleton(),
              noItemsFoundIndicatorBuilder: (final context) => ListError(
                  message: Pair<String>(
                      AppLocalizations.of(context)!.noPostsFound,
                      AppLocalizations.of(context)!.makeFriends)),
              itemBuilder: (final context, final dynamic item, final index) =>
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
                                  post: item,
                                  index: index,
                                  user: user,
                                ),
                              ),
                            )
                          : SizedBox(
                              width: size,
                              height: size,
                              child: PostWidget(
                                post: item,
                                index: index,
                                user: user,
                              ),
                            ),
            ),
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }
}
