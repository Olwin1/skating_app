import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:flutter/services.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:flutter_overlay/flutter_overlay.dart";
import "package:patinka/api/config.dart";
import "package:patinka/api/social.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/profile/profile_page/options_menu.dart";
import "package:patinka/profile/profile_page/page_structure.dart";
import "package:patinka/profile/profile_page/post_footer.dart";
import "package:patinka/services/navigation_service.dart";
import "package:patinka/swatch.dart";
import "package:provider/provider.dart";
import "package:shimmer/shimmer.dart";

// Define item type for popup menu
enum DropdownPage { editProfile, settings, saved }

String? currentImage;
void setCurrentImage(final String img) {
  currentImage = img;
}

// Define a new StatelessWidget called ProfilePage
class ProfilePage extends StatelessWidget {
  // Constructor for ProfilePage, which calls the constructor for its superclass (StatelessWidget)
  const ProfilePage(
      {required this.userId, required this.navbar, super.key, this.friend});
  final String userId;
  final bool navbar;
  final bool? friend;

  // Override the build method of StatelessWidget to return a Consumer widget
  @override
  Widget build(final BuildContext context) => navbar
      ? Consumer<NavigationService>(
          builder: (final context, final navigationService, final _) {
          final int a = NavigationService.getCurrentIndex();
          commonLogger.d("Profile paege i: $a");
          return a == 4
              ? Profile(userId: userId)
              :
              // Otherwise, return an empty SizedBox widget
              const SizedBox.shrink();
        })
      : Profile(
          userId: userId,
          friend: friend,
        );
}

// Creates a ProfilePage widget
class Profile extends StatefulWidget {
  const Profile(
      {required this.userId,
      super.key,
      this.user,
      this.friend}); // Take 2 arguments: optional key and required title of the post
  final String userId;
  final Map<String, dynamic>? user;
  final bool? friend;

  @override
  // Create state for the widget
  State<Profile> createState() => _Profile();
}

// The state class for the ProfilePage widget
class _Profile extends State<Profile> {
  List<Map<String, dynamic>> posts = [];

  Map<String, dynamic>? post;

  bool likedState = false; // Flag for the liked state of the post
  bool savedState = false; // Flag for the liked state of the post
  String comments = "0";
  final backgroundColor = const Color(0xbb000000);

  void setCommentState(final int count) {
    if (mounted) {
      setState(() => comments = count.toString());
    }
  }

  Function setAllStates = (final bool saved, final bool liked, final int count,
      final Map<String, dynamic> postData) {};

  ///

  void _show(final Map<String, dynamic> post) async {
    // Fetch post data
    final postData = await SocialAPI.getPost(post["post_id"]);

    SchedulerBinding.instance.addPostFrameCallback((final _) async {
      setAllStates(postData["saved"], postData["liked"],
          postData["comment_count"], postData);
    });

    // Show dialog with updated information
    if (mounted) {
      HiOverlay.show(
        context,
        child: StatefulBuilder(
          builder: (final BuildContext context, final StateSetter setState) =>
              _dialogContent(setState),
        ),
      );
    }
  }

  Widget _dialogContent(final StateSetter setState) {
    setAllStates = (final bool saved, final bool liked, final int count,
        final Map<String, dynamic> postData) {
      if (mounted) {
        setState(() {
          savedState = saved;
          likedState = liked;
          comments = count.toString();
          post = postData;
        });
      }
    };
    return GestureDetector(
      onTap: () {
        setAllStates = (final bool saved, final bool liked, final int count,
            final Map<String, dynamic> postData) {};
        Navigator.pop(context, "close");
      },
      child: currentImage != null
          ? Container(
              color: const Color(0x55000000),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 124),
              child: Column(
                children: [
                  SizedBox(
                      width: 300,
                      height: 300,
                      child: Stack(children: [
                        Column(children: [
                          const SizedBox(
                            height: 290,
                          ),
                          Container(
                              height: 10, width: 300, color: backgroundColor)
                        ]),
                        CachedNetworkImage(
                          imageUrl: "${Config.uri}/image/$currentImage",
                          imageBuilder: (final context, final imageProvider) =>
                              Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.contain),
                            ),
                          ),
                        ),
                      ])),
                  PostFooter(
                    likedState: likedState,
                    savedState: savedState,
                    setSavedState: (final bool val) {
                      setState(() => savedState = val);
                    },
                    post: post,
                    comments: comments,
                    user: user,
                    backgroundColor: backgroundColor,
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Map<String, dynamic>? user;
  String? avatar;
  @override
  void initState() {
    if (widget.user == null) {
      SocialAPI.getUser(widget.userId).then((final value) => {
            if (mounted)
              {
                setState(() {
                  user = value;
                  avatar = value["avatar_id"];
                })
              }
          });
    }
    super.initState();
  }

  void findWidgetMetaData(final List<Map<String, dynamic>> page) {
    posts.addAll(page);
  }

  @override
  Widget build(final BuildContext context) {
    if (widget.user != null) {
      user = widget.user;
      if (widget.user!["avatar_id"] != null && avatar == null) {
        avatar = widget.user!["avatar_id"];
      }
    }
    return Scaffold(
        backgroundColor: const Color(0x33000000),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          iconTheme: IconThemeData(color: swatch[701]),
          elevation: 8,
          shadowColor: Colors.green.shade900,
          backgroundColor: Config.appbarColour,
          foregroundColor: Colors.transparent,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          // Create appBar widget
          title: user?["username"] != null
              ? Text(
                  user?["username"] ?? AppLocalizations.of(context)!.username,
                  style: TextStyle(color: swatch[801]),
                )
              : Shimmer.fromColors(
                  baseColor: shimmer["base"]!,
                  highlightColor: shimmer["highlight"]!,
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 24.0,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  )), // Set title
          actions: widget.userId == "0"
              ? [
                  // Define icon buttons
                  OptionsMenu(
                    user: user,
                  )
                ]
              : null,
        ),
        // Basic list layout element
        body: PageStructure(
          avatar: avatar,
          user: user,
          userId: widget.userId,
          show: _show,
          setCurrentImage: setCurrentImage,
          friend: widget.friend,
          findWidgetMetaData: findWidgetMetaData,
        ));
  }
}
