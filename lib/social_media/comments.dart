// Import necessary packages and files
import "package:comment_box/comment/comment.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:patinka/api/config/config.dart";
import "package:patinka/api/social.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/misc/navbar_provider.dart";
import "package:patinka/social_media/comment.dart";
import "package:patinka/social_media/utils/components/list_view/default_item_list.dart";
import "package:patinka/social_media/utils/components/list_view/paging_controller.dart";
import "package:patinka/social_media/utils/pair.dart";
import "package:patinka/swatch.dart";
import "package:provider/provider.dart";
import "package:patinka/misc/notifications/error_notification.dart"
    as error_notification;

// Initialize an empty list to store new comments
List<Map<String, dynamic>> newComments = [];

// Comments Widget - Represents the page where comments are displayed
class Comments extends StatefulWidget {
  const Comments({
    required this.post,
    required this.user,
    super.key,
  });
  final String post;

  final Map<String, dynamic>? user;

  @override
  State<Comments> createState() => _Comments();
}

class _Comments extends State<Comments> {
  late FocusNode focus;
  Key commentsListKey = const Key("commentsList");
  late TextEditingController commentController = TextEditingController();
  String userId = "0";
  final GenericStateController<Map<String, dynamic>> genericStateController =
      GenericStateController(key: const Key("connectionsList"));

  @override
  void initState() {
    // Initialize the state and set up the focus node and comment controller
    storage.getId().then((final value) => userId = value ?? "0");
    storage
        .getMuted()
        .then((final result) => setState(() => mutedData = result));
    super.initState();
  }

  Map<String, dynamic>? mutedData;

  @override
  Widget build(final BuildContext context) {
    final bool isMuted = mutedData?["isMuted"] ?? false;

    // Hide the bottom navigation bar when entering the comment screen
    Provider.of<BottomBarVisibilityProvider>(context, listen: false).hide();

    // Create a new focus node every time the widget is built
    focus = FocusNode();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (final bool didPop, final result) {
        // Show the bottom navigation bar when leaving the comment screen
        if (didPop) {
          Provider.of<BottomBarVisibilityProvider>(context, listen: false)
              .show();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0x66000000),
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: buildAppBar(context),
        body: CommentBox(
          focusNode: focus,
          userImage: CommentBox.commentImageParser(
            imageURLorPath: widget.user == null ||
                    widget.user!["avatar_id"] == null
                ? "assets/icons/hand.png"
                : '${Config.uri}/image/thumbnail/${widget.user!["avatar_id"]}',
          ),
          labelText: AppLocalizations.of(context)!.writeComment,
          errorText: "Comment cannot be blank",
          withBorder: false,
          commentController: commentController,
          sendButtonMethod: () {
            // Post a comment when the send button is pressed
            if (!isMuted && commentController.text.isNotEmpty) {
              SocialAPI.postComment(widget.post, commentController.text)
                  .then((final value) => genericStateController.refresh());

              commentController.clear();
            } else {
              // If the user is muted display a notification to say so
              error_notification.showNotification(
                  context, "You're Muted. Try again later.");
              // Clear message so it feels the same as normal
              commentController.clear();
            }
          },
          backgroundColor: swatch[50],
          textColor: swatch[801],
          sendWidget: Icon(Icons.send_sharp,
              size: 30, color: !isMuted ? swatch[801] : Colors.grey.shade800),
          child: CommentsListView(
              key: commentsListKey,
              post: widget.post,
              focus: focus,
              genericStateController: genericStateController),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of the focus node and comment controller to prevent memory leaks
    focus.dispose();
    commentController.dispose();
    super.dispose();
  }

  // Build the app bar for the comments screen
  AppBar buildAppBar(final BuildContext context) => AppBar(
        iconTheme: IconThemeData(color: swatch[701]),
        elevation: 8,
        shadowColor: Colors.green.shade900,
        backgroundColor: Config.appbarColour,
        foregroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        leadingWidth: 48,
        centerTitle: false,
        title: Title(
          title: AppLocalizations.of(context)!.commentsTitle,
          color: const Color(0xFFDDDDDD),
          child: Text(
            AppLocalizations.of(context)!.commentsTitle,
            style: TextStyle(color: swatch[601]),
          ),
        ),
      );
}

// CommentsListView Widget - Represents the list view of comments
class CommentsListView extends StatefulWidget {
  const CommentsListView(
      {required this.focus,
      required this.post,
      required this.genericStateController,
      super.key});
  final FocusNode focus;
  final String post;
  final GenericStateController<Map<String, dynamic>> genericStateController;

  @override
  State<CommentsListView> createState() => _CommentsListViewState();
}

class _CommentsListViewState extends State<CommentsListView> {
  Future<List<Map<String, dynamic>>?> _getNextPage(
      final int pageKey, final int pageSize) async {
    // Fetch the page of comments using the getComments() function
    final page = [
      ...await SocialAPI.getComments(widget.post, pageKey),
      ...newComments
    ];

    // Clear added comments
    newComments.clear();
    return page;
  }

  @override
  void initState() {
    widget.genericStateController.init(
        this,
        (final newState) => setState(
            () => widget.genericStateController.pagingState = newState),
        _getNextPage,
        (final _) => []);
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    if (newComments.isNotEmpty) {
      // If there are new comments, refresh the list view
      widget.genericStateController.refresh();
    }

    // Build a paginated list view of comments using the PagedListView widget
    return DefaultItemList(
      genericStateController: widget.genericStateController,
      itemBuilder: (final context, final item, final index) =>
          buildCommentWidget(index, item),
      noItemsFoundMessage: Pair<String>("No Comments", ""),
    );
  }

  // To show on back page store the reference
  BottomBarVisibilityProvider? bottomBarVisibilityProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bottomBarVisibilityProvider =
        Provider.of<BottomBarVisibilityProvider>(context, listen: false);
  }

  @override
  void dispose() {
    try {
      // Call the show method stored previously
      bottomBarVisibilityProvider?.show();
    } catch (e) {
      commonLogger.e("An error has occurred: $e");
    }
    super.dispose();
  }

  // Build the Comment widget for the given index and item
  Widget buildCommentWidget(final int index, final Map<String, dynamic> item) =>
      index == 0
          ? Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Comment(index: index, focus: widget.focus, comment: item),
            )
          : Comment(index: index, focus: widget.focus, comment: item);
}
