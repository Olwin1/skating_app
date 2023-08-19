import 'package:comment_box/comment/comment.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/social_media/private_messages/comment.dart';
import 'package:patinka/swatch.dart';

import '../api/social.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../components/list_error.dart';

class Comments extends StatefulWidget {
  final String post;

  // Create HomePage Class
  const Comments({Key? key, required this.post})
      : super(key: key); // Take 2 arguments optional key and title of post
  @override
  State<Comments> createState() => _Comments(); //Create state for widget
}

class _Comments extends State<Comments> {
  // Create a focus node to handle focus events
  late FocusNode focus;

  // Initialize a text editing controller to handle text input
  late TextEditingController commentController = TextEditingController();

  // Initialize an empty list to store new comments
  List<Map<String, dynamic>> newComments = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Create a new focus node every time the widget is built
    focus = FocusNode();

    return Scaffold(
      appBar: AppBar(
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
      ),
      body: CommentBox(
        focusNode: focus,
        userImage: CommentBox.commentImageParser(
          imageURLorPath: "assets/placeholders/150.png",
        ),
        labelText: AppLocalizations.of(context)!.writeComment,
        errorText: 'Comment cannot be blank',
        withBorder: false,

        // Pass the comment controller to the CommentBox widget
        commentController: commentController,

        // Define the function to execute when the send button is pressed
        sendButtonMethod: () {
          if (commentController.text.isNotEmpty) {
            // Call the postComment function with the current post and the comment text
            SocialAPI.postComment(widget.post, commentController.text);

            // Clear the comment controller and update the UI with the new comment
            mounted
                ? setState(() {
                    newComments = [
                      ...newComments,
                      (<String, dynamic>{
                        "_id": "newPost",
                        "post": widget.post,
                        "sender": "userid",
                        "content": commentController.text,
                        "like_users": [],
                        "dislike_users": [],
                        "date": DateTime.now().toString()
                      })
                    ];
                  })
                : null;
            commentController.clear();
          }
        },
        backgroundColor: swatch[50],
        textColor: swatch[801],
        sendWidget: Icon(Icons.send_sharp, size: 30, color: swatch[801]),
        child: CommentsListView(
          // Pass the current post, focus node, and new comments to the CommentsListView widget
          post: widget.post,
          focus: focus,
          newComments: newComments,
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
}

class CommentsListView extends StatefulWidget {
  final FocusNode focus;
  final String post;

  final List<Map<String, dynamic>> newComments;

  const CommentsListView(
      {super.key,
      required this.focus,
      required this.post,
      required this.newComments});

  @override
  State<CommentsListView> createState() => _CommentsListViewState();
}

class _CommentsListViewState extends State<CommentsListView> {
  // Number of items per page
  static const _pageSize = 20;

  // The controller that manages pagination
  final PagingController<int, Map<String, dynamic>> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    // Add a listener for page requests, and call _fetchPage() when a page is requested
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      // Fetch the page of comments using the getComments() function
      final page = [
        ...await SocialAPI.getComments(
          widget.post,
          pageKey,
        ),
        ...widget.newComments
      ];

      // Determine if this is the last page
      final isLastPage = page.length < _pageSize;
      if (!mounted) return;
      if (isLastPage) {
        // If this is the last page, append it to the list of pages
        _pagingController.appendLastPage(page);
      } else {
        // If this is not the last page, append it to the list of pages and request the next page
        final nextPageKey = pageKey += 1;
        _pagingController.appendPage(page, nextPageKey);
      }
    } catch (error) {
      // If there's an error fetching the page, set the error on the controller
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.newComments.isNotEmpty) {
      // If there are new comments, refresh the list view
      _pagingController.refresh();
    }

    // Build a paginated list view of comments using the PagedListView widget
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: const AssetImage("assets/backgrounds/graffiti.png"),
              fit: BoxFit.cover,
              alignment: Alignment.bottomRight,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5), BlendMode.srcOver)),
        ),
      ),
      PagedListView<int, Map<String, dynamic>>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
          noItemsFoundIndicatorBuilder: (context) => ListError(
              title: AppLocalizations.of(context)!.noCommentsFound, body: ""),
          // Use the Comment widget to build each item in the list view
          itemBuilder: (context, item, index) => Comment(
            index: index,
            focus: widget.focus,
            comment: item,
          ),
        ),
      )
    ]);
  }

  @override
  void dispose() {
    try {
      // Dispose the controller when the widget is disposed
      _pagingController.dispose();
    } catch (e) {
      commonLogger.e("An error has occured: $e");
    }
    super.dispose();
  }
}
