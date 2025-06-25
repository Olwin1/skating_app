// ignore_for_file: use_super_parameters

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:patinka/api/config/config.dart";
import "package:patinka/api/support.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/l10n/app_localizations.dart";
import "package:patinka/misc/navbar_provider.dart";
import "package:patinka/profile/settings/list_type.dart";
import "package:patinka/swatch.dart";
import "package:provider/provider.dart";

class SupportReportCreator extends StatefulWidget {
  // Create SupportReportCreator Class
  const SupportReportCreator({final Key? key, this.defaultType})
      : super(key: key);
  final SupportListType? defaultType;
  @override
  State<SupportReportCreator> createState() =>
      _SupportReportCreator(); //Create state for widget
}

class _SupportReportCreator extends State<SupportReportCreator> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void initState() {
    reportType = widget.defaultType;
    super.initState();
  }

  SupportListType? reportType;
  void setType(final SupportListType type) {
    setState(() {
      reportType = type;
    });
  }

  @override // Override existing build method
  Widget build(final BuildContext context) {
    String reportTitle = "Report Title";
    String reportTitleHint = "";
    String reportDescription = "Report Description";
    String reportDescriptionHint = "";
    bool enabled = true;
    switch (reportType) {
      case SupportListType.bug:
        reportTitle = "Bug Report Title";
        reportTitleHint = "Breif Outline of Bug";
        reportDescription = "Report Description";
        reportDescriptionHint =
            "Please include a detailed explanation of the issue you have encountered.";
      case SupportListType.suggestion:
        reportTitle = "Feature Request Title";
        reportTitleHint = "Name your suggestion";
        reportDescription = "Feature Description";
        reportDescriptionHint =
            "Please include a detailed description of your proposed feature for the app.";
      case SupportListType.support:
        reportTitle = "Support Request Title";
        reportTitleHint = "Breif title for your problem";
        reportDescription = "Extra Info";
        reportDescriptionHint =
            "Please put a description of what you need help with.";
      case null:
        enabled = false;
    }
    Provider.of<BottomBarVisibilityProvider>(context, listen: false)
        .hide(); // Hide The Navbar
// This function is used to create a session and send information to the server
    void sendInfo() {
      try {
        // Call createSession function with necessary parameters4
        switch (reportType) {
          case SupportListType.bug:
            SupportAPI.submitBugReport(
                titleController.text, descriptionController.text);
          case SupportListType.suggestion:
            SupportAPI.submitFeatureRequest(
                titleController.text, descriptionController.text);
          case SupportListType.support:
            SupportAPI.submitSupportRequest(
                titleController.text, descriptionController.text);
          case null:
            return;
        }

        // Clear the text fields
        titleController.clear();
        descriptionController.clear();
        // Call the callback function with a value of 0.0 to reset distance
        //widget.callback(0.0);
        // Close the current screen and go back to the previous screen
        Navigator.of(context).pop();
      } catch (e) {
        // If there is an error, print the error message to the console
        commonLogger.e("An Error Occurred: $e");
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
          // Create appBar
          leadingWidth: 48, // Remove extra leading space
          centerTitle: false, // Align title to left
          title: Title(
            title: reportType.toString(), //Set title to Save Session
            color: const Color(0xFFDDDDDD),
            child: Text(
              "Create Report",
              style: TextStyle(color: swatch[701]),
            ),
          ),
        ),
        body: Stack(clipBehavior: Clip.none, children: [
          Container(
              decoration: const BoxDecoration(color: Color(0x58000000)),
              padding: const EdgeInsets.all(16)),
          Container(
              padding: const EdgeInsets.all(48),
              child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Left align children
                    // Split layout into individual rows
                    children: [
                      const SizedBox(
                        height: 64,
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(125, 0, 0, 0),
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                margin: const EdgeInsets.symmetric(
                                  // Add margin
                                  vertical: 16,
                                ),
                                decoration: const BoxDecoration(
                                    color: Color.fromARGB(125, 0, 0, 0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Report Type",
                                        style: TextStyle(color: swatch[401])),
                                    SupportListTypeOptions(
                                      defaultValue: reportType,
                                      callback: setType,
                                    )
                                  ],
                                )), // Session Type Infobox
                            Text(reportTitle,
                                style: TextStyle(color: swatch[401])),
                            TextField(
                                maxLength: 100,
                                decoration: InputDecoration(
                                  hintText: reportTitleHint,
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: swatch[200]!),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: swatch[401]!),
                                  ),
                                ),
                                cursorColor: swatch[801],
                                style: TextStyle(color: swatch[801]),
                                controller: titleController,
                                autofocus: true,
                                enabled: enabled),
                          ],
                        ),
                      ), // Session Name Infobox
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(125, 0, 0, 0),
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(reportDescription,
                                style: TextStyle(color: swatch[401])),
                            TextField(
                              decoration: InputDecoration(
                                hintText: reportDescriptionHint,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: swatch[200]!),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: swatch[401]!),
                                ),
                              ),
                              cursorColor: swatch[801],
                              style: TextStyle(color: swatch[801]),
                              maxLines: 4,
                              minLines: 4,
                              maxLength: 350,
                              controller: descriptionController,
                              autofocus: true,
                              enabled: enabled,
                            ),
                          ],
                        ),
                      ), // Session Description Infobox
                      const SizedBox(
                        height: 16,
                      ), // Vertically centre Widget with remaining space
                      TextButton(
                        onPressed: sendInfo,
                        child: Text("Submit Support Report",
                            style: TextStyle(color: swatch[701])),
                      ), // Save Session Infobox
                    ],
                  )))
        ]));
  }
}

class SupportListTypeOptions extends StatefulWidget {
  // Constructor for the SupportListTypeOptions widget
  // Takes in a required `id` property to distinguish between two SupportListTypeOptions widgets
  const SupportListTypeOptions(
      {required this.callback, required this.defaultValue, super.key});
  final Function callback;
  final SupportListType? defaultValue;

  // Returns the state object associated with this widget
  @override
  State<SupportListTypeOptions> createState() => _SupportListTypeOptionsState();
}

class _SupportListTypeOptionsState extends State<SupportListTypeOptions> {
  // `dropdownValueB` holds the selected value for the second dropdown
  SupportListType? dropdownValue;
  String? sdropdownValue(final SupportListType? type) {
    switch (type) {
      case SupportListType.suggestion:
        return "Feature Request";
      case SupportListType.support:
        return "Support Request";
      case SupportListType.bug:
        return "Bug Report";
      case null:
        return null;
      // default:
      //   throw ArgumentError("Invalid value: $type");
    }
  }

  @override
  void initState() {
    dropdownValue = widget.defaultValue;
    super.initState();
  }

  SupportListType rdropdownValue(final String value) {
    switch (value) {
      case "Feature Request":
        return SupportListType.suggestion;
      case "Support Request":
        return SupportListType.support;
      case "Bug Report":
        return SupportListType.bug;
      default:
        throw ArgumentError("Invalid value: $value");
    }
  }

  @override
  Widget build(final BuildContext context) => DropdownButton<String>(
        hint: Text(AppLocalizations.of(context)!.selectReportType),
        iconEnabledColor: swatch[200],
        // Set the value of the dropdown to `dropdownValueA` if `widget.id` is 1,
        // otherwise set it to `dropdownValueB`
        value: sdropdownValue(dropdownValue),

        // Icon to display at the right of the dropdown button
        icon: const Icon(Icons.arrow_downward),

        // Elevation of the dropdown when it's open
        elevation: 16,

        // Style for the text inside the dropdown button
        style: TextStyle(color: swatch[701]),

        padding: const EdgeInsets.all(8),

        // Style for the line under the dropdown button
        underline: Container(
          height: 2,
          color: swatch[200],
        ),
        dropdownColor: swatch[900],
        // Callback function called when an item is selected
        onChanged: (final String? value) {
          SupportListType val = SupportListType.bug;
          switch (value) {
            case "Feature Request":
              val = SupportListType.suggestion;
            case "Support Request":
              val = SupportListType.support;
          }
          mounted
              ? setState(() {
                  // Update the selected value in the corresponding `dropdownValue`
                  // depending on the value of `widget.id`
                  dropdownValue = val;
                })
              : null;
          widget.callback(rdropdownValue(value ?? "Bug Report"));
        },

        // Items to show in the dropdown
        items: [
          sdropdownValue(SupportListType.bug)!,
          sdropdownValue(SupportListType.suggestion)!,
          sdropdownValue(SupportListType.support)!
        ]
            .map<DropdownMenuItem<String>>(
                (final String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ))
            .toList(),
      );
}
