// Import necessary packages and files
import "package:comment_box/comment/comment.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:infinite_scroll_pagination/infinite_scroll_pagination.dart";
import "package:patinka/api/config.dart";
import "package:patinka/api/reports.dart";
import "package:patinka/api/social.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/components/list_error.dart";
import "package:patinka/misc/navbar_provider.dart";
import "package:patinka/swatch.dart";
import "package:provider/provider.dart";

import "package:timeago/timeago.dart" as timeago;

// Initialize an empty list to store new comments
List<Map<String, dynamic>> newReportMessages = [];

// ReportMessages Widget - Represents the page where comments are displayed
class ReportMessages extends StatefulWidget {
  const ReportMessages({
    required this.report,
    required this.user,
    required this.isSelf,
    super.key,
  });
  final String report;
  final bool isSelf;

  final Map<String, dynamic>? user;

  @override
  State<ReportMessages> createState() => _ReportMessages();
}

class _ReportMessages extends State<ReportMessages> {
  late FocusNode focus;
  Key commentsListKey = const Key("commentsList");
  late TextEditingController commentController = TextEditingController();
  String userId = "0";
  final PagingController<int, Map<String, dynamic>> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    // Initialize the state and set up the focus node and comment controller
    storage.getId().then((final value) => userId = value ?? "0");
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    // Hide the bottom navigation bar when entering the comment screen
    Provider.of<BottomBarVisibilityProvider>(context, listen: false).hide();

    // Create a new focus node every time the widget is built
    focus = FocusNode();

    return !widget.isSelf
        ? CommentBox(
            focusNode: focus,
            userImage: CommentBox.commentImageParser(
              imageURLorPath: widget.user == null ||
                      widget.user!["avatar_id"] == null
                  ? "assets/icons/hand.png"
                  : '${Config.uri}/image/thumbnail/${widget.user!["avatar_id"]}',
            ),
            labelText: AppLocalizations.of(context)!.writeComment,
            errorText: "Message cannot be blank",
            withBorder: false,
            commentController: commentController,
            sendButtonMethod: () {
              // Post a comment when the send button is pressed
              if (commentController.text.isNotEmpty) {
                ReportAPI.postReportMessage(
                        widget.report, commentController.text)
                    .then((final value) => _pagingController.refresh());

                commentController.clear();
              }
            },
            backgroundColor: swatch[50],
            textColor: swatch[801],
            sendWidget: Icon(Icons.send_sharp, size: 30, color: swatch[801]),
            child: ReportMessagesListView(
                key: commentsListKey,
                report: widget.report,
                focus: focus,
                pagingController: _pagingController),
          )
        : ReportMessagesListView(
            key: commentsListKey,
            report: widget.report,
            focus: focus,
            pagingController: _pagingController);
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

// ReportMessagesListView Widget - Represents the list view of comments
class ReportMessagesListView extends StatefulWidget {
  const ReportMessagesListView(
      {required this.focus,
      required this.report,
      required this.pagingController,
      super.key});
  final FocusNode focus;
  final String report;
  final PagingController<int, Map<String, dynamic>> pagingController;

  @override
  State<ReportMessagesListView> createState() => _ReportMessagesListViewState();
}

class _ReportMessagesListViewState extends State<ReportMessagesListView> {
  static const _pageSize = 20; // Number of items per page

  @override
  void initState() {
    // Add a listener for page requests, and call _fetchPage() when a page is requested
    widget.pagingController.addPageRequestListener(_fetchPage);
    super.initState();
  }

  Future<void> _fetchPage(final int pageKey) async {
    try {
      // Fetch the page of comments using the getReportMessages() function
      final page = [
        ...await ReportAPI.getReportMessages(pageKey, widget.report),
        ...newReportMessages
      ];

      // Determine if this is the last page
      final isLastPage = page.length < _pageSize;
      if (!mounted) {
        return;
      }
      if (isLastPage) {
        // If this is the last page, append it to the list of pages
        widget.pagingController.appendLastPage(page);
      } else {
        // If this is not the last page, append it to the list of pages and request the next page
        final nextPageKey = pageKey + 1;
        widget.pagingController.appendPage(page, nextPageKey);
      }
    } catch (error) {
      // If there's an error fetching the page, set the error on the controller
      widget.pagingController.error = error;
    }
  }

  @override
  Widget build(final BuildContext context) {
    if (newReportMessages.isNotEmpty) {
      // If there are new comments, refresh the list view
      widget.pagingController.refresh();
    }

    // Build a paginated list view of comments using the PagedListView widget
    return PagedListView<int, Map<String, dynamic>>(
      pagingController: widget.pagingController,
      builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
        noItemsFoundIndicatorBuilder: (final context) => const ListError(
            title: "No Updates Yet.", body: "Maybe try checking again later. "),
        itemBuilder: (final context, final item, final index) =>
            buildMessageWidget(index, item),
      ),
    );
  }

  @override
  void dispose() {
    try {
      // Dispose the controller when the widget is disposed
      widget.pagingController.dispose();
    } catch (e) {
      commonLogger.e("An error has occurred: $e");
    }
    super.dispose();
  }

  // Build the Message widget for the given index and item
  Widget buildMessageWidget(final int index, final Map<String, dynamic> item) =>
      index == 0
          ? Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Message(index: index, focus: widget.focus, comment: item),
            )
          : Message(index: index, focus: widget.focus, comment: item);
}

// Message Widget class for displaying individual comments
class Message extends StatefulWidget {
  // Constructor for Message widget
  const Message({
    required this.index,
    required this.focus,
    required this.comment,
    super.key,
  });
  final Map<String, dynamic> comment;
  final int index;
  final FocusNode focus;

  @override
  State<Message> createState() =>
      _MessageState(); // Create state for the Message widget
}

// State class for the Message widget
class _MessageState extends State<Message> {
  Map<String, dynamic>? user;

  // Initialize state variables and fetch user information
  @override
  void initState() {
    SocialAPI.getUser(widget.comment["sender_id"]).then((final value) => mounted
        ? setState(() {
            user = value;
          })
        : null);
    super.initState();
  }

  // Build method to create the UI of the Message widget
  @override
  Widget build(final BuildContext context) => Container(
        // Container for each comment
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: swatch[401]!)),
          color: const Color.fromARGB(125, 0, 0, 0),
        ),
        padding: const EdgeInsets.all(8),
        child: Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display user name and time since the comment
              RichText(
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: "Moderator User",
                      style: TextStyle(color: swatch[101], fontSize: 16),
                    ),
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: SizedBox(width: 6),
                    ),
                    TextSpan(
                      text: timeago
                          .format(DateTime.parse(widget.comment["timestamp"])),
                      style: TextStyle(color: swatch[501]),
                    ),
                  ],
                ),
              ),
              // Display comment content
              Text(
                widget.comment["content"],
                textAlign: TextAlign.start,
                style: TextStyle(color: swatch[801], fontSize: 15),
              ),
            ],
          ),
        ),
      );
}