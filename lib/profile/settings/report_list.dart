import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:patinka/api/reports.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/components/list_error.dart';
import 'package:patinka/profile/settings/status_colour.dart';
import 'package:patinka/services/role.dart';
import 'package:patinka/social_media/post_widget.dart';

import '../../api/config.dart';
import '../../swatch.dart';
import 'report_user.dart';

// FollowingList widget

class ReportList extends StatelessWidget {
  final Map<String, dynamic>? user;
  const ReportList({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    String title = "Reports";

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
        body: ReportListView(
          user: user,
        ));
  }
}

class ReportListView extends StatefulWidget {
  final Map<String, dynamic>? user;

  const ReportListView({super.key, required this.user});

  @override
  State<ReportListView> createState() => _ReportListViewState();
}

class _ReportListViewState extends State<ReportListView> {
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
      page = await ReportAPI.getReports(pageKey);

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
          itemBuilder: (context, item, index) => ReportListWidget(
            item: item,
            refreshPage: _pagingController.refresh,
            user: widget.user,
          ),
          noItemsFoundIndicatorBuilder: (context) =>
              const ListError(title: "No reports", body: "Well thats nice."),
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
      commonLogger.e("Error in dispose: $e");
    }
    super.dispose();
  }
}

// UserListWidget class creates a stateful widget that displays a list of users
class ReportListWidget extends StatefulWidget {
  // Constructor for UserListWidget
  const ReportListWidget(
      {super.key,
      required this.item,
      required this.refreshPage,
      required this.user});

  // Title for the widget
  final Map<String, dynamic> item;
  final Map<String, dynamic>? user;
  final VoidCallback refreshPage;
  // Creates the state for the UserListWidget
  @override
  State<ReportListWidget> createState() => _ReportListWidget();
}

// _UserListWidget class is the state of the UserListWidget
class _ReportListWidget extends State<ReportListWidget> {
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
        pageBuilder: (context, animation, secondaryAnimation) => UserReportPage(
            report: widget.item, user: widget.user, userRole: userRole),
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
    Color statusColour = StatusColour.getColour(widget.item["status"]);
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
                        widget.item["report_id"],
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
                      Text("Subject:"),
                      Container(
                          margin: const EdgeInsets.only(left: 8),
                          height: 28,
                          width: 28,
                          child: Avatar(user: widget.item["reported_user_id"])),
                    ]),
                    Text(
                      widget.item["reported_content"],
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
                          child: SizedBox(
                              width: 110,
                              child: Text(
                                widget.item["status"],
                                style: TextStyle(overflow: TextOverflow.fade, backgroundColor: Colors.black.withAlpha(150)),
                              ))),
                      const SizedBox(
                        width: 45,
                      ),
                      const Text("By:"),
                      Container(
                          margin: const EdgeInsets.only(left: 8),
                          height: 28,
                          width: 28,
                          child: Avatar(user: widget.item["reporter_id"])),
                    ]),
                  ])),
              IconButton(
                  onPressed: () => commonLogger.i(widget.item["reporter_id"]),
                  icon: const Icon(Icons.navigate_next))
            ])));
  }
}
