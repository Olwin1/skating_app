// Import necessary packages and files
import 'package:comment_box/comment/comment.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:patinka/api/config.dart';
import 'package:patinka/api/support.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/components/list_error.dart';
import 'package:patinka/profile/settings/list_type.dart';
import 'package:patinka/services/role.dart';
import 'package:patinka/swatch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'report_message.dart';

// Initialize an empty list to store new messages
List<Map<String, dynamic>> newMessages = [];

// Messages Widget - Represents the page where messages are displayed
class Messages extends StatefulWidget {
  final String feedbackId;
  final SupportListType reportType;

  const Messages(
      {super.key,
      required this.feedbackId,
      required this.user,
      required this.reportType,
      required this.status});

  final Map<String, dynamic>? user;
  final Status status;

  @override
  State<Messages> createState() => _Messages();
}

class _Messages extends State<Messages> {
  late FocusNode focus;
  Key commentsListKey = const Key("supportMessagesList");
  late TextEditingController commentController = TextEditingController();
  String userId = "0";
  final PagingController<int, Map<String, dynamic>> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    // Initialize the state and set up the focus node and message controller
    storage.getId().then((value) => userId = value ?? "0");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Create a new focus node every time the widget is built
    focus = FocusNode();
    if (widget.status != Status.closed) {
      return CommentBox(
        focusNode: focus,
        userImage: CommentBox.commentImageParser(
          imageURLorPath: widget.user == null ||
                  widget.user!["avatar_id"] == null
              ? "assets/icons/hand.png"
              : '${Config.uri}/image/thumbnail/${widget.user!["avatar_id"]}',
        ),
        labelText: AppLocalizations.of(context)!.message,
        errorText: 'Message cannot be blank',
        withBorder: false,
        commentController: commentController,
        sendButtonMethod: () {
          // Post a message when the send button is pressed
          if (commentController.text.isNotEmpty) {
            SupportAPI.postMessage(widget.feedbackId, commentController.text)
                .then((value) => _pagingController.refresh());

            commentController.clear();
          }
        },
        backgroundColor: swatch[50],
        textColor: swatch[801],
        sendWidget: Icon(Icons.send_sharp, size: 30, color: swatch[801]),
        child: MessagesListView(
            status: widget.status,
            key: commentsListKey,
            post: widget.feedbackId,
            focus: focus,
            pagingController: _pagingController,
            reportType: widget.reportType),
      );
    } else {
      return Stack(children: [
        MessagesListView(
            status: widget.status,
            key: commentsListKey,
            post: widget.feedbackId,
            focus: focus,
            pagingController: _pagingController,
            reportType: widget.reportType),
        Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                height: 100,
                color: const Color(0xcc000000),
                child: const Center(
                    child: Column(children: [
                  Text(
                    "This Report Has Been Marked As Closed.",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text("Reports marked as closed cannot be modified.")
                ]))))
      ]);
    }
  }

  @override
  void dispose() {
    // Dispose of the focus node and message controller to prevent memory leaks
    focus.dispose();
    commentController.dispose();
    super.dispose();
  }
}

// MessagesListView Widget - Represents the list view of messages
class MessagesListView extends StatefulWidget {
  final FocusNode focus;
  final String post;
  final PagingController<int, Map<String, dynamic>> pagingController;
  final SupportListType reportType;
  final Status status;

  const MessagesListView({
    super.key,
    required this.focus,
    required this.post,
    required this.pagingController,
    required this.reportType,
    required this.status,
  });

  @override
  State<MessagesListView> createState() => _MessagesListViewState();
}

class _MessagesListViewState extends State<MessagesListView> {
  static const _pageSize = 20; // Number of items per page

  @override
  void initState() {
    // Add a listener for page requests, and call _fetchPage() when a page is requested
    widget.pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      // Fetch the page of messages using the getComments() function
      final page = [
        ...await SupportAPI.getMessages(widget.post, pageKey),
        ...newMessages
      ];

      // Determine if this is the last page
      final isLastPage = page.length < _pageSize;
      if (!mounted) return;
      if (isLastPage) {
        // If this is the last page, append it to the list of pages
        widget.pagingController.appendLastPage(page);
      } else {
        // If this is not the last page, append it to the list of pages and request the next page
        final nextPageKey = pageKey += 1;
        widget.pagingController.appendPage(page, nextPageKey);
      }
    } catch (error) {
      // If there's an error fetching the page, set the error on the controller
      widget.pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height - 350;
    if (newMessages.isNotEmpty) {
      // If there are new messages, refresh the list view
      widget.pagingController.refresh();
    }

    // Build a paginated list view of messages using the PagedListView widget
    return PagedListView<int, Map<String, dynamic>>(
      pagingController: widget.pagingController,
      builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
        noItemsFoundIndicatorBuilder: (context) =>
            const ListError(title: "", body: "Awaiting Response"),
        itemBuilder: (context, item, index) =>
            buildCommentWidget(index, item, height),
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
  Widget buildCommentWidget(
      int index, Map<String, dynamic> item, double height) {
    return index == 0
        ? Padding(
            padding: EdgeInsets.only(top: height),
            child: ReportMessage(
                index: index,
                focus: widget.focus,
                message: item,
                status: widget.status),
          )
        : ReportMessage(
            index: index,
            focus: widget.focus,
            message: item,
            status: widget.status);
  }
}
