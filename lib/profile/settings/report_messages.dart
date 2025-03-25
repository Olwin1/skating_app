// Import necessary packages and files
import "package:comment_box/comment/comment.dart";
import "package:flutter/material.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:patinka/api/config.dart";
import "package:patinka/api/support.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/profile/settings/list_type.dart";
import "package:patinka/profile/settings/report_message.dart";
import "package:patinka/services/role.dart";
import "package:patinka/social_media/utils/components/list_view/default_item_list.dart";
import "package:patinka/social_media/utils/components/list_view/paging_controller.dart";
import "package:patinka/social_media/utils/pair.dart";
import "package:patinka/swatch.dart";

// Initialize an empty list to store new messages
List<Map<String, dynamic>> newMessages = [];

// Messages Widget - Represents the page where messages are displayed
class Messages extends StatefulWidget {
  const Messages(
      {required this.feedbackId,
      required this.user,
      required this.reportType,
      required this.status,
      super.key});
  final String feedbackId;
  final SupportListType reportType;

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
  final GenericPagingController<Map<String, dynamic>> genericPagingController =
      GenericPagingController(key: const Key("connectionsList"));

  @override
  void initState() {
    // Initialize the state and set up the focus node and message controller
    storage.getId().then((final value) => userId = value ?? "0");
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
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
        errorText: "Message cannot be blank",
        withBorder: false,
        commentController: commentController,
        sendButtonMethod: () {
          // Post a message when the send button is pressed
          if (commentController.text.isNotEmpty) {
            SupportAPI.postMessage(widget.feedbackId, commentController.text)
                .then((final value) =>
                    genericPagingController.pagingController.refresh());

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
            genericPagingController: genericPagingController,
            reportType: widget.reportType),
      );
    } else {
      return Stack(children: [
        MessagesListView(
            status: widget.status,
            key: commentsListKey,
            post: widget.feedbackId,
            focus: focus,
            genericPagingController: genericPagingController,
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
  const MessagesListView({
    required this.focus,
    required this.post,
    required this.genericPagingController,
    required this.reportType,
    required this.status,
    super.key,
  });
  final FocusNode focus;
  final String post;
  final GenericPagingController<Map<String, dynamic>> genericPagingController;
  final SupportListType reportType;
  final Status status;

  @override
  State<MessagesListView> createState() => _MessagesListViewState();
}

class _MessagesListViewState extends State<MessagesListView> {
  Future<List<Map<String, dynamic>>?> getPage(final int pageKey) async {
    // Fetch the page of messages using the getComments() function
    final page = [
      ...await SupportAPI.getMessages(widget.post, pageKey),
      ...newMessages
    ];

    if (!mounted) {
      return null;
    }
    return page;
  }

  @override
  void initState() {
    widget.genericPagingController.initialize(getPage, null);
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    final double height = MediaQuery.of(context).size.height - 350;
    if (newMessages.isNotEmpty) {
      // If there are new messages, refresh the list view
      widget.genericPagingController.pagingController.refresh();
    }

    // Build a paginated list view of messages using the PagedListView widget
    return DefaultItemList(
      pagingController: widget.genericPagingController.pagingController,
      itemBuilder: (final context, final item, final index) =>
          buildCommentWidget(index, item, height),
      noItemsFoundMessage: Pair<String>("No Messages", ""),
    );
  }

  @override
  void dispose() {
    try {
      // Dispose the controller when the widget is disposed
      widget.genericPagingController.pagingController.dispose();
    } catch (e) {
      commonLogger.e("An error has occurred: $e");
    }
    super.dispose();
  }

  // Build the Message widget for the given index and item
  Widget buildCommentWidget(final int index, final Map<String, dynamic> item,
          final double height) =>
      index == 0
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
