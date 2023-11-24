// Importing necessary packages and files
import 'package:flutter/material.dart';
import 'package:patinka/common_logger.dart';

import '../../swatch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// OverlaySettings widget

// Define an enumeration of themes: light, dark, and system default
enum Theme { light, dark, sysDefault }

// A private class that represents the state of the OverlaySettings widget
class OverlaySettings {
  // If item is 1, return a container with a form to change the password
  void password(BuildContext context) {
    showDialog(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(200, 0, 0, 0),
          title: Text(
            'Change Password',
            style: TextStyle(color: swatch[701]),
          ),
          content: Container(
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
                    onPressed: () => commonLogger.i("pressed"),
                    child: Text(AppLocalizations.of(context)!.changePassword)),
              ])),
        );
      },
    );
  }

  // If item is 2, return a container with a list of languages to choose from
  void languages(BuildContext context) {
    showDialog(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(200, 0, 0, 0),
          title: Text(
            'Select Language',
            style: TextStyle(color: swatch[701]),
          ),
          content: Container(
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
          ),
        );
      },
    );
  }

// If item is 3, return a container with a list of radio buttons to select a theme
  void theme(BuildContext context) {
    showDialog(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(200, 0, 0, 0),
          title: Text(
            'Select theme',
            style: TextStyle(color: swatch[701]),
          ),
          content: const SelectThemeWidget(),
        );
      },
    );
  }

  void features(BuildContext context) {
    showDialog(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(200, 0, 0, 0),
          title: Text(
            'Planned Upcoming features',
            style: TextStyle(color: swatch[701]),
          ),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color.fromARGB(200, 0, 0, 0),
            ),
            height: 300,
            width: 250,
            key: const Key("2"),
            child: ListView(padding: const EdgeInsets.all(8), children: const [
              Text(
                  "Friends tracker - search for places, people, and recent sessions"),
              SizedBox(height: 8),
              Text("Friends tracker - Nearby skateparks"),
              SizedBox(height: 8),
              Text("Friends tracker - Nearby areas suitable for skating"),
              SizedBox(height: 8),
              Text("Messaging - Image sending in messages"),
              SizedBox(height: 8),
              Text("Messaging - Image link embedding in messages"),
              SizedBox(height: 8),
              Text(
                  "Localisation - Add support for localisation across whole of app"),
              SizedBox(height: 8),
              Text(
                  "Fitness tracker - Make speedometer default to use accelerometer before using GPS"),
              SizedBox(height: 8),
              Text(
                  "Fitness Tracker - Make sunset time tappable to change to sunrise time the next day"),
              SizedBox(height: 8),
              Text(
                  "Fitness Tracker - Make avg session duration & avg speed functional"),
              SizedBox(height: 8),
              Text("Profile Page - Add more post controls on profile page"),
              SizedBox(height: 8),
              Text(
                  "Style - Make background customisable though a selectable list of styalised backgrounds."),
              SizedBox(height: 8),
              Text("Errors - Add more helpful error messages"),
              SizedBox(height: 8),
              Text(
                  "Security - Make server less trusting and check things more"),
              SizedBox(height: 8),
              Text(
                  "Posts - Videos - Add support for short videos (but not like shorts)"),
              SizedBox(height: 8),
              Text("Save posts - Make posts save-able"),
              SizedBox(height: 8),
              Text("Comments - Improve post comments"),
              SizedBox(height: 8),
              Text("Bug - Fix default avatar on navbar on login"),
              SizedBox(height: 8),
              Text("Bug - Fix cache not updating on data change"),
              SizedBox(height: 8),
              Text("Port to web"),
              SizedBox(height: 8),
              Text("Port to windows"),
              SizedBox(height: 8),
              Text("Port to iOS? -- Far Future")
            ]),
          ),
        );
      },
    );
  }
}

class SelectThemeWidget extends StatefulWidget {
  const SelectThemeWidget({super.key});

  @override
  State<SelectThemeWidget> createState() => _SelectThemeWidget();
}

class _SelectThemeWidget extends State<SelectThemeWidget> {
  Theme? _theme = Theme.sysDefault;

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => commonLogger.i("pressed"),
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
