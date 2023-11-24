import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:patinka/api/config.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/social_media/private_messages/private_message_list.dart';
import 'package:patinka/social_media/search_bar.dart';
import '../api/fcm_token.dart';
import '../api/messages.dart';
import '../api/social.dart';
import '../components/list_error.dart';
import '../misc/navbar_provider.dart';
import '../swatch.dart';
import 'post_widget.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// HomePage Class
class HomePage extends StatelessWidget {
  HomePage({super.key});
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // Show the Navbar
    Provider.of<BottomBarVisibilityProvider>(context, listen: false).show();

    return Scaffold(
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
                _scrollController.animateTo(0,
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
                builder: (context) => const PrivateMessageList(
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
          scrollController: _scrollController,
        ),
      ),
    );
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

// Posts List View Widget
class PostsListView extends StatefulWidget {
  const PostsListView({super.key, required this.scrollController});

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
    // Initialize State
    MessagesAPI.getUserId().then((userId) {
      if (userId != null) {
        SocialAPI.getUser(userId).then((userA) {
          user = userA;
        });
      }
    });

    // Get FCM Token (excluding Windows and Linux)
    if (!(Platform.isWindows || Platform.isLinux)) {
      FirebaseMessaging.instance
          .getToken()
          .then((fcmToken) => fcmToken != null ? updateToken(fcmToken) : null);
    }

    // Add Page Request Listener
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    super.initState();
  }

  // Fetches the data for the given pageKey and appends it to the list of items
  Future<void> _fetchPage(int pageKey) async {
    try {
      commonLogger.t("Fetching page");
      final page = await SocialAPI.getPosts(pageKey);

      // Loops through each item in the page and adds its ID to the `seenPosts` list
      for (int i = 0; i < page.length; i++) {
        Map<String, dynamic> item = page[i];
        seenPosts.add(item['post_id']);
      }

      // Determines if the page being fetched is the last page
      final isLastPage = page.isEmpty;
      if (!mounted) return;
      if (isLastPage) {
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
        _pagingController.appendPage(page, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  // Refresh Page Function
  Future<void> refreshPage() async {
    seenPosts = [];
    _pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double size = height >= width ? width : height;
    if (size > 1080) {
      size = 1080;
    }

    return Stack(
      children: [
        RefreshIndicator(
          edgeOffset: 94,
          onRefresh: () => refreshPage(),
          child: PagedListView<int, Object>(
            clipBehavior: Clip.none,
            cacheExtent: 1024,
            pagingController: _pagingController,
            scrollController: widget.scrollController,
            builderDelegate: PagedChildBuilderDelegate<Object>(
              firstPageProgressIndicatorBuilder: (context) => _loadSkeleton(),
              noItemsFoundIndicatorBuilder: (context) => ListError(
                title: AppLocalizations.of(context)!.noPostsFound,
                body: AppLocalizations.of(context)!.makeFriends,
              ),
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

  @override
  void dispose() {
    // Dispose of the PagingController to free up resources
    _pagingController.dispose();
    super.dispose();
  }
}

/*
Nearby skateparks
gen areas
scout hut opposite



*/