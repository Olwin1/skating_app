import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patinka/api/config.dart';
import 'package:patinka/api/reports.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/profile/settings/status_colour.dart';
import 'package:patinka/profile/settings/status_dropdown.dart';
import 'package:patinka/services/role.dart';
import 'package:patinka/social_media/post_widget.dart';
import 'package:patinka/social_media/report_content_type.dart';
import 'package:patinka/swatch.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

// Define a StatefulWidget for the Report page
class UserReportPage extends StatefulWidget {
  final Map<String, dynamic> report;
  final Map<String, dynamic>? user;
  final UserRole userRole;

  const UserReportPage(
      {super.key,
      required this.report,
      required this.user,
      required this.userRole});
  @override
  State<UserReportPage> createState() => _UserReportPage();
}

// Define the State for the Report page
class _UserReportPage extends State<UserReportPage> {
  String? status;
  dynamic content;
  String? selectedNewStatus;

  @override
  void initState() {
    setState(() {
      status = widget.report["status"];
    });

    ReportAPI.getReportData(
            widget.report["report_id"],
            widget.report["reported_content"] == "post"
                ? ReportContentType.post
                : widget.report["reported_content"] == "comment"
                    ? ReportContentType.comment
                    : ReportContentType.message)
        .then((response) {
      setState(() {
        content = response;
      });
    });
    super.initState();
  }

  Widget loadStatusIcon(Color statusColour) {
    if (widget.userRole != UserRole.moderator ||
        widget.userRole == UserRole.administrator) {
      return StatusDropdown(
          report: widget.report,
          onStatusChanged: (a) {
            print("Update request status");
          });
    }
    return Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: statusColour, borderRadius: BorderRadius.circular(16)),
        child: Text(
          status ?? "",
          style: TextStyle(backgroundColor: Colors.black.withAlpha(150)),
        ));
  }

  @override
  Widget build(BuildContext context) {
    Color statusColour =
        status != null ? StatusColour.getColour(status!) : Colors.transparent;

    Widget reportedContentPreview = SizedBox.shrink();
    if (content != null) {
      commonLogger.d("UPDATING");
      switch (widget.report["reported_content"]) {
        case "post":
          reportedContentPreview = Column(children: [
            SizedBox(
              height: 350,
              width: 350,
              child: ZoomOverlay(
                // Zoomable overlay for the post image
                modalBarrierColor: Colors.black12,
                minScale: 0.5,
                maxScale: 3.0,
                animationCurve: Curves.fastOutSlowIn,
                animationDuration: const Duration(milliseconds: 600),
                twoTouchOnly: true,
                child: CachedNetworkImage(
                  // Post image loaded from the network
                  imageUrl: "${Config.uri}/image/${content!["image"]}",
                  placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: shimmer["base"]!,
                      highlightColor: shimmer["highlight"]!,
                      child: Image.asset("assets/placeholders/1080.png")),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8)),
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
                color: Colors.black,
                child: Text(
                  content!["description"],
                  style: TextStyle(fontSize: 16),
                ))
          ]);
          break;
        case "comment":
          reportedContentPreview = Text(content!["content"]);
          break;
        case "message":
          reportedContentPreview = SizedBox(
              height: 500,
              child: ListView.builder(
                  itemCount: content!.length,
                  itemBuilder: (context, index) {
                    return Container(
                        margin: EdgeInsets.all(8),
                        color: widget.report["reported_content_id"] ==
                                content![index]["message_id"]
                            ? Colors.blue.shade900
                            : Colors.green.shade800,
                        child: Column(children: [
                          Text(
                            timeago.format(
                                DateTime.parse(content![index]["date_sent"])),
                            style: TextStyle(fontSize: 16),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                  height: 36,
                                  width: 36,
                                  child: Avatar(
                                      user: content![index]["sender_id"])),
                              SizedBox(
                                width: 10,
                              ),
                              Text(content![index]["sender_id"])
                            ],
                          ),
                          Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.black),
                              child: Text(content![index]["content"],
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.pink))),
                        ]));
                  }));
          break;
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
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
        leadingWidth: 48,
        centerTitle: false,
        title: Title(
          title: "Report",
          color: const Color(0xFFDDDDDD),
          child: Text(
            widget.report["reported_content"],
            style: TextStyle(color: swatch[701]),
          ),
        ),
      ),
      body: Column(children: [
        Container(
            decoration:
                const BoxDecoration(color: Color.fromARGB(88, 62, 23, 23)),
            child: IntrinsicHeight(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xbb000000),
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.only(
                    left: 8, right: 8, top: 114, bottom: 4),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeago
                            .format(DateTime.parse(widget.report["timestamp"])),
                        style: TextStyle(
                          color: swatch[801],
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                      Text(
                        widget.report["reported_content_id"],
                        style: TextStyle(color: swatch[801], fontSize: 15),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                      Row(children: [
                        const Text("Status:"),
                        loadStatusIcon(statusColour),
                      ]),
                    ]),
              ),
            )),
        reportedContentPreview,
        Container(
          color: Colors.blueGrey,
          height: 100,
          child: Row(children: [
            DropdownMenu(
                onSelected: (String? selectedElement) {
                  selectedNewStatus = selectedElement;
                },
                dropdownMenuEntries: StatusColour.getStatusList()
                    .map<DropdownMenuEntry<String>>(((String item) {
                  return DropdownMenuEntry<String>(value: item, label: item);
                })).toList()),
            TextButton(
                onPressed: () async {
                  String? newStatus = selectedNewStatus;
                  if (newStatus == null) {
                    return;
                  }
                  try {
                    await ReportAPI.modifyReportStatus(
                        widget.report["report_id"], newStatus);
                    setState(() {
                      status = newStatus;
                    });
                  } catch (e) {
                    commonLogger
                        .e("An Error Occured During Status Modification: $e");
                  }
                },
                child: Text("Submit"))
          ]),
        )
      ]),
    );
  }
}
