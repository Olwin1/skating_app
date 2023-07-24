import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:patinka/api/session.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/swatch.dart';

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
// This function is used to create a session and send information to the server
    void sendInfo() {
      try {
        // Call createSession function with necessary parameters
        createSession(
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

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          // Create appBar
          leadingWidth: 48, // Remove extra leading space
          centerTitle: false, // Align title to left
          title: Title(
            title: AppLocalizations.of(context)!
                .saveSession, //Set title to Save Session
            color: const Color(0xFFDDDDDD),
            child: Text(AppLocalizations.of(context)!.saveSession),
          ),
        ),
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: const AssetImage("assets/backgrounds/graffiti.png"),
                  fit: BoxFit.cover,
                  alignment: Alignment.topRight,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5), BlendMode.srcOver)),
            ),
            padding: const EdgeInsets.all(48),
            child: ListView(
              // crossAxisAlignment:
              //     CrossAxisAlignment.start, // Left align children
              // Split layout into individual rows
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center Children
                  // Top 2 elements
                  children: [
                    Flexible(
                      flex: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(125, 0, 0, 0),
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        // Distance Traveled Box
                        margin: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.distanceTraveled,
                              style: TextStyle(color: swatch[401]),
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ), // Title
                            Text(
                                "${(widget.distance / 1000).toStringAsFixed(2)}km",
                                style: TextStyle(color: swatch[601])) // Value
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                        flex: 16,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(125, 0, 0, 0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          // Session Duration Box
                          margin: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.sessionDuration,
                                style: TextStyle(color: swatch[401]),
                                overflow: TextOverflow.fade,
                                softWrap: false,
                              ), // Title

                              Text(
                                  widget.endTime
                                      .difference(widget.startTime)
                                      .toString()
                                      .substring(0, 8),
                                  style: TextStyle(color: swatch[601])) // Value
                            ],
                          ),
                        ))
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(125, 0, 0, 0),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Column(
                    children: [
                      Text(AppLocalizations.of(context)!.sessionName,
                          style: TextStyle(color: swatch[401])),
                      TextField(
                        maxLength: 100,
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: swatch[200]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: swatch[401]!),
                          ),
                        ),
                        cursorColor: swatch[601],
                        style: TextStyle(color: swatch[601]),
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
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Column(
                    children: [
                      Text(AppLocalizations.of(context)!.sessionDescription,
                          style: TextStyle(color: swatch[401])),
                      TextField(
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: swatch[200]!),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: swatch[401]!),
                          ),
                        ),
                        cursorColor: swatch[601],
                        style: TextStyle(color: swatch[601]),
                        maxLines: 4,
                        minLines: 4,
                        maxLength: 350,
                        controller: descriptionController,
                        autofocus: true,
                      ),
                    ],
                  ),
                ), // Session Description Infobox
                const Spacer(), // Add small gap
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(125, 0, 0, 0),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: TextButton(
                      onPressed: () => commonLogger.i("Add photos"),
                      child: Text(AppLocalizations.of(context)!.addPhotos)),
                ), // Add Photos Infobox
                Container(
                    margin: const EdgeInsets.symmetric(
                      // Add margin
                      vertical: 16,
                    ),
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(125, 0, 0, 0),
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Column(
                      children: [
                        Text(AppLocalizations.of(context)!.sessionType,
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
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Column(
                      children: [
                        Text(AppLocalizations.of(context)!.shareOptions,
                            style: TextStyle(color: swatch[401])),
                        ShareOptions(
                          callback: setOptions,
                        )
                      ],
                    )), // Share to Infobox
                const Spacer(
                  flex: 2,
                ), // Vertically centre Widget with remaining space
                TextButton(
                  onPressed: () => sendInfo(),
                  child: Text(AppLocalizations.of(context)!.saveSession,
                      style: TextStyle(color: swatch[701])),
                ), // Save Session Infobox
                const Spacer(
                  flex: 2,
                )
              ],
            )));
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
