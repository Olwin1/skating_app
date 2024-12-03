// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:patinka/api/session.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/misc/navbar_provider.dart';
import 'package:patinka/swatch.dart';
import 'package:provider/provider.dart';

import '../api/config.dart';

const List<String> sessionType = <String>[
  'Recreational/Fitness Skating',
  'Agressive Inline Skating',
  'Agressive Quad Skating',
  'Artistic/Figure Skating',
  'Urban/Freestyle Skating',
  'Off-Road Skating',
  'Roller Hockey',
  'Ice Hockey',
  'Roller Disco',
  'Roller Derby',
];
const List<String> sessionOptions = <String>['Friends'];

class SaveSession extends StatefulWidget {
  // Create SaveSession Class
  const SaveSession(
      {Key? key,
      required this.distance,
      required this.startTime,
      required this.endTime,
      required this.callback,
      required this.initialPosition})
      : super(key: key);
  final double distance;
  final DateTime startTime;
  final DateTime endTime;
  final Function callback;
  final Position initialPosition;
  @override
  State<SaveSession> createState() => _SaveSession(); //Create state for widget
}

class _SaveSession extends State<SaveSession> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  String sessionType = "Fitness";
  String sessionOptions = "Friends";
  void setType(String type) {
    sessionType = type;
  }

  void setOptions(String options) {
    sessionOptions = options;
  }

  @override // Override existing build method
  Widget build(BuildContext context) {
    Provider.of<BottomBarVisibilityProvider>(context, listen: false)
        .hide(); // Hide The Navbar
// This function is used to create a session and send information to the server
    void sendInfo() {
      try {
        // Call createSession function with necessary parameters
        SessionAPI.createSession(
            nameController.text, // Name of the session
            descriptionController.text, // Description of the session
            [], // Empty array of images
            sessionType, // Type of the session
            sessionOptions, // Session sharing options
            widget.startTime, // Start time of the session
            widget.endTime, // End time of the session
            (widget.distance * 100)
                .round(), // Distance of the session in meters
            widget.initialPosition.latitude,
            widget.initialPosition.longitude);
        // Clear the text fields
        nameController.clear();
        descriptionController.clear();
        // Call the callback function with a value of 0.0 to reset distance
        widget.callback(0.0);
        // Close the current screen and go back to the previous screen
        Navigator.of(context).pop();
      } catch (e) {
        // If there is an error, print the error message to the console
        commonLogger.e("An Error Occurred: $e");
      }
    }

    return PopScope(
        canPop: true,
        onPopInvokedWithResult: (bool didPop, result) {
          if (didPop) {
            Provider.of<BottomBarVisibilityProvider>(context, listen: false)
                .show(); // Show The Navbar
          }
        },
        child: Scaffold(
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
                title: AppLocalizations.of(context)!
                    .saveSession, //Set title to Save Session
                color: const Color(0xFFDDDDDD),
                child: Text(
                  AppLocalizations.of(context)!.saveSession,
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
                          FittedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FittedBox(
                                  // Set a fixed width for the first container
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(125, 0, 0, 0),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                    margin: const EdgeInsets.all(8),
                                    child: Column(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .distanceTraveled,
                                          style: TextStyle(color: swatch[401]),
                                          overflow: TextOverflow.fade,
                                          softWrap: false,
                                        ),
                                        Text(
                                          "${(widget.distance / 1000).toStringAsFixed(2)}km",
                                          style: TextStyle(color: swatch[601]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                    width:
                                        16), // Add some spacing between the two containers
                                FittedBox(
                                  // Set a fixed width for the second container
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(125, 0, 0, 0),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                    margin: const EdgeInsets.all(8),
                                    child: Column(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .sessionDuration,
                                          style: TextStyle(color: swatch[401]),
                                          overflow: TextOverflow.fade,
                                          softWrap: false,
                                        ),
                                        Text(
                                          widget.endTime
                                              .difference(widget.startTime)
                                              .toString()
                                              .substring(0, 8),
                                          style: TextStyle(color: swatch[601]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(125, 0, 0, 0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Column(
                              children: [
                                Text(AppLocalizations.of(context)!.sessionName,
                                    style: TextStyle(color: swatch[401])),
                                TextField(
                                  maxLength: 100,
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: swatch[200]!),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: swatch[401]!),
                                    ),
                                  ),
                                  cursorColor: swatch[801],
                                  style: TextStyle(color: swatch[801]),
                                  controller: nameController,
                                  autofocus: true,
                                ),
                              ],
                            ),
                          ), // Session Name Infobox
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(125, 0, 0, 0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Column(
                              children: [
                                Text(
                                    AppLocalizations.of(context)!
                                        .sessionDescription,
                                    style: TextStyle(color: swatch[401])),
                                TextField(
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: swatch[200]!),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: swatch[401]!),
                                    ),
                                  ),
                                  cursorColor: swatch[801],
                                  style: TextStyle(color: swatch[801]),
                                  maxLines: 4,
                                  minLines: 4,
                                  maxLength: 350,
                                  controller: descriptionController,
                                  autofocus: true,
                                ),
                              ],
                            ),
                          ), // Session Description Infobox
                          //const Spacer(), // Add small gap
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(125, 0, 0, 0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: TextButton(
                                onPressed: () => commonLogger.i("Add photos"),
                                child: Text(
                                  AppLocalizations.of(context)!.addPhotos,
                                  style: TextStyle(color: swatch[201]),
                                )),
                          ), // Add Photos Infobox
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
                                children: [
                                  Text(
                                      AppLocalizations.of(context)!.sessionType,
                                      style: TextStyle(color: swatch[401])),
                                  SessionType(
                                    callback: setType,
                                  )
                                ],
                              )), // Session Type Infobox
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
                                children: [
                                  Text(
                                      AppLocalizations.of(context)!
                                          .shareOptions,
                                      style: TextStyle(color: swatch[401])),
                                  ShareOptions(
                                    callback: setOptions,
                                  )
                                ],
                              )), // Share to Infobox
                          const SizedBox(
                            height: 16,
                          ), // Vertically centre Widget with remaining space
                          TextButton(
                            onPressed: () => sendInfo(),
                            child: Text(
                                AppLocalizations.of(context)!.saveSession,
                                style: TextStyle(color: swatch[701])),
                          ), // Save Session Infobox
                        ],
                      )))
            ])));
  }
}

class SessionType extends StatefulWidget {
  final Function callback;

  // Constructor for the ShareOptions widget
  // Takes in a required `id` property to distinguish between two ShareOptions widgets
  const SessionType({super.key, required this.callback});

  // Returns the state object associated with this widget
  @override
  State<SessionType> createState() => _SessionTypeState();
}

class _SessionTypeState extends State<SessionType> {
  // `dropdownValueA` holds the selected value for the first dropdown
  String dropdownValue = sessionType.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
        iconEnabledColor: swatch[200],
        value: dropdownValue,
        // Icon to display at the right of the dropdown button
        icon: const Icon(Icons.arrow_downward),

        // Elevation of the dropdown when it's open
        elevation: 16,

        // Style for the text inside the dropdown button
        style: TextStyle(color: swatch[701]),

        // Style for the line under the dropdown button
        underline: Container(
          height: 2,
          color: swatch[200],
        ),
        dropdownColor: swatch[900],

        // Callback function called when an item is selected
        onChanged: (String? value) {
          mounted
              ? setState(() {
                  // Update the selected value in the corresponding `dropdownValue`
                  // depending on the value of `widget.id`
                  dropdownValue = value!;
                })
              : null;
          widget.callback(value);
        },

        // Items to show in the dropdown
        items: sessionType.map<DropdownMenuItem<String>>((String value) {
          // Create a dropdown item for each value in `sessionType`
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList()
        // Create a dropdown item for each value in `sessionOptions`
        );
  }
}

class ShareOptions extends StatefulWidget {
  final Function callback;
  // Constructor for the ShareOptions widget
  // Takes in a required `id` property to distinguish between two ShareOptions widgets
  const ShareOptions({super.key, required this.callback});

  // Returns the state object associated with this widget
  @override
  State<ShareOptions> createState() => _ShareOptionsState();
}

class _ShareOptionsState extends State<ShareOptions> {
  // `dropdownValueB` holds the selected value for the second dropdown
  String dropdownValue = sessionOptions.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      iconEnabledColor: swatch[200],
      // Set the value of the dropdown to `dropdownValueA` if `widget.id` is 1,
      // otherwise set it to `dropdownValueB`
      value: dropdownValue,

      // Icon to display at the right of the dropdown button
      icon: const Icon(Icons.arrow_downward),

      // Elevation of the dropdown when it's open
      elevation: 16,

      // Style for the text inside the dropdown button
      style: TextStyle(color: swatch[701]),

      // Style for the line under the dropdown button
      underline: Container(
        height: 2,
        color: swatch[200],
      ),
      dropdownColor: swatch[900],
      // Callback function called when an item is selected
      onChanged: (String? value) {
        mounted
            ? setState(() {
                // Update the selected value in the corresponding `dropdownValue`
                // depending on the value of `widget.id`
                dropdownValue = value!;
              })
            : null;
        widget.callback(value);
      },

      // Items to show in the dropdown
      items: sessionOptions.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
