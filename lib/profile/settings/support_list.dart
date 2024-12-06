import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:patinka/api/support.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/components/list_error.dart';
import 'package:patinka/profile/settings/report.dart';
import 'package:patinka/services/role.dart';
import 'package:patinka/social_media/post_widget.dart';
import 'create_report.dart';

import '../../api/config.dart';
import '../../swatch.dart';
import 'list_type.dart';

// FollowingList widget

class SupportList extends StatelessWidget {
  final SupportListType type;
  final Map<String, dynamic>? user;
  const SupportList({super.key, required this.type, required this.user});

  @override
  Widget build(BuildContext context) {
    String title = "Reports";
    switch (type) {
      case SupportListType.suggestion:
        title = "Your Suggestions";
        break;

      case SupportListType.bug:
        title = "Bug Reports";
        break;

      case SupportListType.support:
        title = "Support Requests";
        break;
    }
    return Scaffold(
        backgroundColor: const Color(0x34000000),
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        extendBody: true,
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
            title: Text(
              title,
              style: TextStyle(color: swatch[701]),
            )),
        body: SupportListView(
          user: user,
          type: type,
        ));
  }
}

class SupportListView extends StatefulWidget {
  final SupportListType type;
  final Map<String, dynamic>? user;

  const SupportListView({super.key, required this.type, required this.user});

  @override
  State<SupportListView> createState() => _SupportListViewState();
}

class _SupportListViewState extends State<SupportListView> {
  // Number of items per page
  static const _pageSize = 20;

  // The controller that manages pagination
  final PagingController<int, Map<String, dynamic>> _pagingController =
      PagingController(firstPageKey: 0);
  UserRole userRole = UserRole.regular;
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
      List<Map<String, dynamic>> page;
      // Fetch the page of comments using the getComments() function
      switch (widget.type) {
        case SupportListType.suggestion:
          page = await SupportAPI.getFeatureRequests(pageKey);
          break;

        case SupportListType.bug:
          page = await SupportAPI.getBugReports(pageKey);
          break;

        case SupportListType.support:
          page = await SupportAPI.getSupportRequests(pageKey);
          break;
      }

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
    // Build a paginated list view of comments using the PagedListView widget
    return Stack(children: [
      PagedListView<int, Map<String, dynamic>>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
          // Use the Comment widget to build each item in the list view
          itemBuilder: (context, item, index) => UserListWidget(
            item: item,
            listType: widget.type,
            refreshPage: _pagingController.refresh,
            user: widget.user,
          ),
          noItemsFoundIndicatorBuilder: (context) =>
              const ListError(title: "No reports", body: "Try creating one!"),
        ),
      ),
      Positioned(
          bottom: 64,
          right: 32,
          child: FloatingActionButton(
            backgroundColor: const Color(0x7711cc11),
            onPressed: () => Navigator.of(context).push(
                // Send to signal info page
                MaterialPageRoute(
                    builder: (context) => SupportReportCreator(
                          defaultType: widget.type,
                        ))),
            child: const Icon(
              Icons.add,
              color: Color(0xb8ffffff),
            ),
          ))
    ]);
  }

  @override
  void dispose() {
    try {
      // Dispose the controller when the widget is disposed
      _pagingController.dispose();
    } catch (e) {
      commonLogger.e("Error in dispose: $e");
    }
    super.dispose();
  }
}

// UserListWidget class creates a stateful widget that displays a list of users
class UserListWidget extends StatefulWidget {
  // Constructor for UserListWidget
  const UserListWidget(
      {super.key,
      required this.item,
      required this.listType,
      required this.refreshPage,
      required this.user});

  // Title for the widget
  final Map<String, dynamic> item;
  final Map<String, dynamic>? user;
  final SupportListType listType;
  final VoidCallback refreshPage;
  // Creates the state for the UserListWidget
  @override
  State<UserListWidget> createState() => _UserListWidget();
}

// _UserListWidget class is the state of the UserListWidget
class _UserListWidget extends State<UserListWidget> {
  UserRole userRole = UserRole.regular;
  @override
  void initState() {
    if (widget.user != null) {
      UserRole tmp = RoleServices.convertToEnum(widget.user!["user_role"]);
      if (tmp != UserRole.regular) {
        setState(() {
          userRole = tmp;
        });
      }
    }
    super.initState();
  }

  void handlePress() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ReportPage(
            report: widget.item,
            user: widget.user,
            reportType: widget.listType,
            userRole: userRole),
        opaque: true,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          var tween = Tween(begin: begin, end: end);
          var fadeAnimation = tween.animate(animation);
          return FadeTransition(
            opacity: fadeAnimation,
            child: child,
          );
        },
      ),
    );
  }

  // Builds the widget
  @override
  Widget build(BuildContext context) {
    bool isOwnReport = true;
    bool isAssignedToUser = false;
    if (widget.user!["user_id"] != widget.item["user_id"]) {
      isOwnReport = false;
      if (widget.user!["user_id"] == widget.item["assigned_to"]) {
        isAssignedToUser = true;
      }
    }
    Color statusColour = widget.item["status"] == "closed"
        ? Colors.red.shade700
        : widget.item["status"] == "open"
            ? swatch[100]!
            : swatch[500]!;
    // Returns a row with a CircleAvatar, a text widget, and a TextButton
    return GestureDetector(
        onTap: () => handlePress(),
        child: Container(
            decoration: BoxDecoration(
              color: const Color(0xbb000000),
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      Text(
                        widget.item["subject"],
                        style: TextStyle(
                          color: swatch[801],
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      !isOwnReport
                          ? !isAssignedToUser
                              ? const Text("Unassigned")
                              : const SizedBox.shrink()
                          : const SizedBox.shrink(),
                    ]),
                    Text(
                      widget.item["content"],
                      style: TextStyle(color: swatch[801], fontSize: 15),
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    Row(children: [
                      const Text("Status:"),
                      Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: statusColour,
                              borderRadius: BorderRadius.circular(16)),
                          child: Text(widget.item["status"])),
                      const SizedBox(
                        width: 45,
                      ),
                      !isOwnReport
                          ? isAssignedToUser
                              ? const Text("Assigned to:")
                              : const Text("Created By:")
                          : const SizedBox.shrink(),
                      !isOwnReport
                          ? isAssignedToUser
                              ? Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  height: 28,
                                  width: 28,
                                  child:
                                      Avatar(user: widget.item["assigned_to"]))
                              : const SizedBox.shrink()
                          : const SizedBox.shrink(),
                      !isOwnReport
                          ? !isAssignedToUser
                              ? Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  height: 28,
                                  width: 28,
                                  child: Avatar(user: widget.item["user_id"]))
                              : const SizedBox.shrink()
                          : const SizedBox.shrink(),
                    ]),
                  ])),
              IconButton(
                  onPressed: () => commonLogger.i("handle icon press"),
                  icon: const Icon(Icons.navigate_next))
            ])));
  }
}
