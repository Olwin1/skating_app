import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patinka/api/config.dart';
import 'package:patinka/profile/settings/report_messages.dart';
import 'package:patinka/swatch.dart';

// Define a StatefulWidget for the Report page
class ReportPage extends StatefulWidget {
  final Map<String, dynamic> report;
  final Map<String, dynamic>? user;
  const ReportPage({super.key, required this.report, required this.user});
  @override
  State<ReportPage> createState() => _ReportPage();
}

// Define the State for the Report page
class _ReportPage extends State<ReportPage> {
  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
          child: ListView(shrinkWrap: true, children: [
            Messages(
              feedbackId: widget.report["feedback_id"],
              user: widget.user,
            )
          ])),
    );
  }
}
