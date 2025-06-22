import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:patinka/api/config/config.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/profile/settings/list_type.dart";
import "package:patinka/profile/settings/report_messages.dart";
import "package:patinka/profile/settings/status_dropdown.dart";
import "package:patinka/services/role.dart";
import "package:patinka/swatch.dart";

// Define a StatefulWidget for the Report page
class ReportPage extends StatefulWidget {
  const ReportPage(
      {required this.report,
      required this.user,
      required this.reportType,
      required this.userRole,
      super.key});
  final Map<String, dynamic> report;
  final Map<String, dynamic>? user;
  final SupportListType reportType;
  final UserRole userRole;
  @override
  State<ReportPage> createState() => _ReportPage();
}

// Define the State for the Report page
class _ReportPage extends State<ReportPage> {
  Status status = Status.closed;

  @override
  void initState() {
    final Status tmpStatus =
        RoleServices.convertToStatus(widget.report["status"]);
    if (tmpStatus != Status.closed) {
      setState(() {
        status = tmpStatus;
      });
    }
    super.initState();
  }

  Widget loadStatusIcon(final Color statusColour) {
    if (widget.userRole != UserRole.moderator ||
        widget.userRole == UserRole.administrator) {
      return StatusDropdown(
          report: widget.report,
          onStatusChanged: (final a) {
            commonLogger.d("Update request status");
          });
    }
    return Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: statusColour, borderRadius: BorderRadius.circular(16)),
        child: Text(widget.report["status"]));
  }

  @override
  Widget build(final BuildContext context) {
    final Color statusColour = status == Status.closed
        ? Colors.red.shade700
        : status == Status.open
            ? swatch[100]!
            : swatch[500]!;
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
            widget.report["subject"],
            style: TextStyle(color: swatch[701]),
          ),
        ),
      ),
      body: DecoratedBox(
          decoration:
              const BoxDecoration(color: Color.fromARGB(88, 62, 23, 23)),
          child: Stack(children: [
            Messages(
                feedbackId: widget.report["feedback_id"],
                user: widget.user,
                reportType: widget.reportType,
                status: status),
            IntrinsicHeight(
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
                        widget.report["subject"],
                        style: TextStyle(
                          color: swatch[801],
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                      Text(
                        widget.report["content"],
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
            )
          ])),
    );
  }
}
