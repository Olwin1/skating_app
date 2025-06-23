// Import necessary packages and files
import "package:comment_box/comment/comment.dart";
import "package:flutter/material.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:patinka/api/config/config.dart";
import "package:patinka/api/support.dart";
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
  final GenericStateController<Map<String, dynamic>> genericStateController =
      GenericStateController(key: const Key("connectionsList"));

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
                .then((final value) => genericStateController.refresh());

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
            genericStateController: genericStateController,
            reportType: widget.reportType),
      );
    } else {
      return Stack(children: [
        MessagesListView(
            status: widget.status,
            key: commentsListKey,
            post: widget.feedbackId,
            focus: focus,
            genericStateController: genericStateController,
            reportType: widget.reportType),
        Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                height: 100,
                color: const Color(0xcc000000),
                child: Center(
                    child: Column(children: [
                  Text(
                    AppLocalizations.of(context)!.reportMarkedAsClosed,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(AppLocalizations.of(context)!
                      .closedReportsCannotBeModified)
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
    required this.genericStateController,
    required this.reportType,
    required this.status,
    super.key,
  });
  final FocusNode focus;
  final String post;
  final GenericStateController<Map<String, dynamic>> genericStateController;
  final SupportListType reportType;
  final Status status;

  @override
  State<MessagesListView> createState() => _MessagesListViewState();
}

class _MessagesListViewState extends State<MessagesListView> {
  Future<List<Map<String, dynamic>>?> _getNextPage(
      final int pageKey, final int pageSize) async {
    // Fetch the page of messages using the getComments() function
    final page = [
      ...await SupportAPI.getMessages(widget.post, pageKey),
      ...newMessages
    ];

// Clear added messages
    newMessages.clear();
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
    final double height = MediaQuery.of(context).size.height - 350;
    if (newMessages.isNotEmpty) {
      // If there are new messages, refresh the list view
      widget.genericStateController.refresh();
    }

    // Build a paginated list view of messages using the PagedListView widget
    return DefaultItemList(
      genericStateController: widget.genericStateController,
      itemBuilder: (final context, final item, final index) =>
          buildCommentWidget(index, item, height),
      noItemsFoundMessage: Pair<String>("No Messages", ""),
    );
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
