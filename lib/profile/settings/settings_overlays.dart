// Importing necessary packages and files
import 'package:flutter/material.dart';

import '../../swatch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color.fromARGB(200, 0, 0, 0),
            ),
            key: const Key("1"),
            padding: const EdgeInsets.all(16),
            child: Wrap(children: [
              Text(
                AppLocalizations.of(context)!.oldPassword,
                style: TextStyle(color: swatch[701]),
              ),
              TextField(
                maxLength: 100,
                style: TextStyle(color: swatch[901]),
                decoration: const InputDecoration(
                    fillColor: Color.fromARGB(255, 0, 0, 0), filled: true),
              ),
              Text(AppLocalizations.of(context)!.newPassword,
                  style: TextStyle(color: swatch[701])),
              TextField(
                maxLength: 100,
                style: TextStyle(color: swatch[901]),
                decoration: const InputDecoration(
                    fillColor: Color.fromARGB(255, 0, 0, 0), filled: true),
              ),
              Text(AppLocalizations.of(context)!.retypePassword,
                  style: TextStyle(color: swatch[701])),
              TextField(
                maxLength: 100,
                style: TextStyle(color: swatch[901]),
                decoration: const InputDecoration(
                    fillColor: Color.fromARGB(255, 0, 0, 0), filled: true),
              ),
              TextButton(
                  onPressed: () => print("pressed"),
                  child: Text(AppLocalizations.of(context)!.changePassword)),
            ]));

      // If item is 2, return a container with a list of languages to choose from
      case 2:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color.fromARGB(200, 0, 0, 0),
          ),
          height: 300,
          width: 250,
          key: const Key("2"),
          child: ListView(padding: const EdgeInsets.all(8), children: [
            // Each language is represented by a LanguagePopupItem widget, which displays
            // the language name and its alternative name.
            LanguagePopupItem(
              name: "English",
              altName: AppLocalizations.of(context)!.english,
            ),
            LanguagePopupItem(
              name: "Polski",
              altName: AppLocalizations.of(context)!.polish,
            ),
            LanguagePopupItem(
              name: "Deutsch",
              altName: AppLocalizations.of(context)!.german,
            ),
            LanguagePopupItem(
              name: "Italiano",
              altName: AppLocalizations.of(context)!.italian,
            ),
            LanguagePopupItem(
              name: "Français",
              altName: AppLocalizations.of(context)!.french,
            )
          ]),
        );

      // If item is 3, return a container with a list of radio buttons to select a theme
      case 3:
        return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color.fromARGB(200, 0, 0, 0),
            ),
            height: 180,
            width: 250,
            key: const Key("3"),
            child: Column(children: [
              ListTile(
                iconColor: swatch[200],
                selectedColor: swatch[400],
                title: Text(
                  AppLocalizations.of(context)!.dark,
                  style: TextStyle(color: swatch[501]),
                ),
                leading: Radio<Theme?>(
                  fillColor: const MainColour(),
                  value: Theme.dark,
                  groupValue: _theme,
                  onChanged: (Theme? value) {
                    mounted
                        ? setState(() {
                            _theme = value;
                          })
                        : null;
                  },
                ),
              ),
              ListTile(
                iconColor: swatch[200],
                selectedColor: swatch[400],
                title: Text(AppLocalizations.of(context)!.light,
                    style: TextStyle(color: swatch[501])),
                leading: Radio<Theme?>(
                  fillColor: const MainColour(),
                  value: Theme.light,
                  groupValue: _theme,
                  onChanged: (Theme? value) {
                    mounted
                        ? setState(() {
                            _theme = value;
                          })
                        : null;
                  },
                ),
              ),
              ListTile(
                iconColor: swatch[900],
                selectedColor: swatch[401],
                title: Text(AppLocalizations.of(context)!.systemDefault,
                    style: TextStyle(color: swatch[501])),
                leading: Radio<Theme?>(
                  fillColor: const MainColour(),
                  value: Theme.sysDefault,
                  groupValue: _theme,
                  onChanged: (Theme? value) {
                    mounted
                        ? setState(() {
                            _theme = value;
                          })
                        : null;
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
                  style: TextStyle(fontSize: 16, color: swatch[50]),
                ),
                Text(
                  widget.altName,
                  style:
                      TextStyle(fontWeight: FontWeight.w700, color: swatch[0]),
                )
              ],
            )));
  }
}

class MainColour extends MaterialStateColor {
  const MainColour() : super(0xffffffff);

  @override
  Color resolve(Set<MaterialState> states) {
    return swatch[301]!;
  }
}
