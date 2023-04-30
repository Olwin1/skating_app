// Importing necessary packages and files
import 'package:flutter/material.dart';

// OverlaySettings widget

// Define an enumeration of themes: light, dark, and system default
enum Theme { light, dark, sysDefault }

// Define a stateful widget for the overlay settings
class OverlaySettings extends StatefulWidget {
  const OverlaySettings({Key? key, required this.item}) : super(key: key);
  final int item;

  // Override the createState method to create the state of the widget
  @override
  State<OverlaySettings> createState() => _OverlaySettings();
}

// A private class that represents the state of the OverlaySettings widget
class _OverlaySettings extends State<OverlaySettings> {
  // Initialize the theme to system default
  Theme? _theme = Theme.sysDefault;

  // Override the build method to build the UI of the widget
  @override
  Widget build(BuildContext context) {
    // Use a switch statement to return a different container for each item
    switch (widget.item) {
      // If item is 0, return an empty container with key "0"
      case 0:
        return Container(key: const Key("0"));

      // If item is 1, return a container with a form to change the password
      case 1:
        return Container(
            height: 300,
            width: 250,
            key: const Key("1"),
            padding: const EdgeInsets.all(16),
            color: const Color(0xffffffff),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Old Password"),
              const TextField(),
              const Text("New Password"),
              const TextField(),
              const Text("Retype Password"),
              const TextField(),
              TextButton(
                  onPressed: () => print("pressed"),
                  child: const Text("Change Password")),
            ]));

      // If item is 2, return a container with a list of languages to choose from
      case 2:
        return Container(
          height: 300,
          width: 250,
          key: const Key("2"),
          color: const Color(0xffffffff),
          child: ListView(padding: const EdgeInsets.all(8), children: const [
            // Each language is represented by a LanguagePopupItem widget, which displays
            // the language name and its alternative name.
            LanguagePopupItem(
              name: "English",
              altName: "English",
            ),
            LanguagePopupItem(
              name: "Polski",
              altName: "Polish",
            ),
            LanguagePopupItem(
              name: "Deutsch",
              altName: "German",
            ),
            LanguagePopupItem(
              name: "Italiano",
              altName: "Italian",
            ),
            LanguagePopupItem(
              name: "Français",
              altName: "French",
            )
          ]),
        );

      // If item is 3, return a container with a list of radio buttons to select a theme
      case 3:
        return Container(
            height: 180,
            width: 250,
            key: const Key("3"),
            color: const Color(0xffffffff),
            child: Column(children: [
              ListTile(
                title: const Text('Dark'),
                leading: Radio<Theme?>(
                  value: Theme.dark,
                  groupValue: _theme,
                  onChanged: (Theme? value) {
                    setState(() {
                      _theme = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Light'),
                leading: Radio<Theme?>(
                  value: Theme.light,
                  groupValue: _theme,
                  onChanged: (Theme? value) {
                    setState(() {
                      _theme = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('System Default'),
                leading: Radio<Theme?>(
                  value: Theme.sysDefault,
                  groupValue: _theme,
                  onChanged: (Theme? value) {
                    setState(() {
                      _theme = value;
                    });
                  },
                ),
              )
            ]));

      default:
        return const Text("testy");
    }
  }
}

class LanguagePopupItem extends StatefulWidget {
  const LanguagePopupItem(
      {super.key, required this.name, required this.altName});
  final String name;
  final String altName;

  @override
  State<LanguagePopupItem> createState() => _LanguagePopupItemState();
}

class _LanguagePopupItemState extends State<LanguagePopupItem> {
  @override
  Widget build(BuildContext context) {
    // Each LanguagePopupItem displays the name of a language and its alternative name
    // using two Text widgets. When the button is pressed, the widget prints "pressed" to the console.
    return Padding(
        padding: const EdgeInsets.all(8),
        child: TextButton(
            style: const ButtonStyle(alignment: Alignment.centerLeft),
            onPressed: () => print("pressed"),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  widget.altName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                )
              ],
            )));
  }
}
