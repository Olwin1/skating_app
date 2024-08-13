import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay/flutter_overlay.dart';
import 'package:patinka/profile/profile_page/options_menu.dart';
import 'package:patinka/profile/profile_page/page_structure.dart';
import 'package:patinka/profile/profile_page/post_footer.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/api/social.dart';

import '../../api/config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../current_tab.dart';
import '../../swatch.dart';

// Define item type for popup menu
enum DropdownPage { editProfile, settings, saved }

String? currentImage;
void setCurrentImage(img) {
  currentImage = img;
}

// Define a new StatelessWidget called ProfilePage
class ProfilePage extends StatelessWidget {
  final String userId;
  final bool navbar;
  final bool? friend;

  // Constructor for ProfilePage, which calls the constructor for its superclass (StatelessWidget)
  const ProfilePage(
      {super.key, required this.userId, required this.navbar, this.friend});

  // Override the build method of StatelessWidget to return a Consumer widget
  @override
  Widget build(BuildContext context) {
    // Use the Consumer widget to listen for changes to the CurrentPage object
    return navbar
        ? Consumer<CurrentPage>(
            builder: (context, currentPage, widget) =>
                // If the CurrentPage's tab value is 4 (The profile page), return a Profile widget
                currentPage.tab == 4
                    ? Profile(userId: userId)
                    :
                    // Otherwise, return an empty SizedBox widget
                    const SizedBox.shrink(),
          )
        : Profile(
            userId: userId,
            friend: friend,
          );
  }
}

// Creates a ProfilePage widget
class Profile extends StatefulWidget {
  const Profile(
      {super.key,
      required this.userId,
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
  // void _show() {
  //   HiOverlay.show(
  //     context,
  //     child: _dialog(),
  //   ).then((value) {
  //     commonLogger.t('Recieved value: $value');
  //   });
  // }

  Map<String, dynamic>? post;

  bool likedState = false; // Flag for the liked state of the post
  bool savedState = false; // Flag for the liked state of the post
  String comments = "0";

  /// SET STATES
  void setLikedState(bool val) {
    if (mounted) {
      setState(() => likedState = val);
    }
  }

  void setSavedState(bool val) {
    if (mounted) {
      setState(() => savedState = val);
    }
  }

  void setCommentState(int count) {
    if (mounted) {
      setState(() => comments = count.toString());
    }
  }

  Function setAllStates = (bool saved, bool liked, int count) {};

  ///

  void _show(Map<String, dynamic> post) async {
    // Fetch post data
    final postData = await SocialAPI.getPost(post["post_id"]);

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      setAllStates(
          postData["saved"], postData["liked"], postData["comment_count"]);
    });

    // Show dialog with updated information
    if (mounted) {
      HiOverlay.show(
        context,
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return _dialogContent(setState);
          },
        ),
      );
    }
  }

  Widget _dialogContent(StateSetter setState) {
    setAllStates = (bool saved, bool liked, int count) {
      if (mounted) {
        setState(() {
          savedState = saved;
          likedState = liked;
          comments = count.toString();
        });
      }
    };
    return GestureDetector(
      onTap: () {
        setAllStates = (bool saved, bool liked, int count) {};
        Navigator.pop(context, 'close');
      },
      child: currentImage != null
          ? Container(
              color: const Color(0x55000000),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 64),
              child: Column(
                children: [
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: CachedNetworkImage(
                      imageUrl: '${Config.uri}/image/$currentImage',
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  ),
                  PostFooter(
                    likedState: likedState,
                    savedState: savedState,
                    setLikedState: (bool val) {
                      setState(() => likedState = val);
                    },
                    setSavedState: (bool val) {
                      setState(() => savedState = val);
                    },
                    post: post,
                    comments: comments,
                    user: user,
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
      SocialAPI.getUser(widget.userId).then((value) => {
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

  void findWidgetMetaData(List<Map<String, dynamic>> page) {
    posts.addAll(page);
  }

  @override
  Widget build(BuildContext context) {
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
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
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
