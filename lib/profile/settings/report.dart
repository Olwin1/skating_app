import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patinka/api/config.dart';
import 'package:patinka/profile/settings/list_type.dart';
import 'package:patinka/profile/settings/report_messages.dart';
import 'package:patinka/swatch.dart';

// Define a StatefulWidget for the Report page
class ReportPage extends StatefulWidget {
  final Map<String, dynamic> report;
  final Map<String, dynamic>? user;
  final SupportListType reportType;

  const ReportPage(
      {super.key,
      required this.report,
      required this.user,
      required this.reportType});
  @override
  State<ReportPage> createState() => _ReportPage();
}

// Define the State for the Report page
class _ReportPage extends State<ReportPage> {
  @override
  Widget build(BuildContext context) {
    Color statusColour = widget.report["status"] == "closed"
        ? Colors.red.shade700
        : widget.report["status"] == "open"
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
      body: Container(
          decoration: const BoxDecoration(color: Color.fromARGB(158, 0, 0, 0)),
          child: Stack(children: [
            Messages(
                feedbackId: widget.report["feedback_id"],
                user: widget.user,
                reportType: widget.reportType),
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
                        Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: statusColour,
                                borderRadius: BorderRadius.circular(16)),
                            child: Text(widget.report["status"]))
                      ]),
                    ]),
              ),
            )
          ])),
    );
  }
}
