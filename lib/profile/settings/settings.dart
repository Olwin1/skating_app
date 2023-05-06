// Importing necessary packages and files
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:skating_app/profile/settings/settings_overlays.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Settings widget

int item = 0;

class Settings extends StatefulWidget {
  const Settings({Key? key, required this.item}) : super(key: key);
  final int item;
  @override
  State<Settings> createState() => _Settings();
}

// Private class that represents the state of the Settings widget
class _Settings extends State<Settings> {
  // When outside pressed set item state to hide overlay
  void outsidePressed() => {item != 0 ? setState(() => item = 0) : null};

  @override
  Widget build(BuildContext context) {
    // Building the UI of the Settings widget
    return Scaffold(
        // AppBar widget for the title of the screen
        appBar: AppBar(
          // Setting the title of the AppBar
          title: Text(AppLocalizations.of(context)!.settings),
        ),
        // Using the SettingsList widget from the settings_ui package
        body: Stack(children: [
          SettingsList(
            sections: [
              // Adding a SettingsSection to group related tiles together
              SettingsSection(
                title: Text(AppLocalizations.of(context)!.security),
                // Adding the tiles to the section
                tiles: <SettingsTile>[
                  // Navigation tile with an email icon, title, and value
                  SettingsTile.navigation(
                    leading: const Icon(Icons.mail),
                    title: Text(AppLocalizations.of(context)!.email),
                    value: const Text("default@example.com"),
                  ),
                  // Navigation tile with a language icon, title, and value
                  SettingsTile.navigation(
                    leading: const Icon(Icons.password),
                    title: Text(AppLocalizations.of(context)!.password),
                    value: const Text('••••••••'),
                    onPressed: (e) => {
                      print("text"),
                      setState(() => {item = 1})
                    },
                  ),
                  // Switch tile for toggling push notifications
                  SettingsTile.switchTile(
                    // Callback function for when the toggle is switched
                    onToggle: (value) {},
                    // Initial value for the toggle
                    initialValue: true,
                    // Icon, title, and switch for the tile
                    leading: const Icon(Icons.fingerprint),
                    title: Text(AppLocalizations.of(context)!.biometrics),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.logout),
                    title: Text(AppLocalizations.of(context)!.logout),
                  ),
                ],
              ),
              SettingsSection(
                title: Text(AppLocalizations.of(context)!.notifications),
                // Adding the tiles to the section
                tiles: <SettingsTile>[
                  // Switch tile for toggling push notifications
                  SettingsTile.switchTile(
                    // Callback function for when the toggle is switched
                    onToggle: (value) {},
                    // Initial value for the toggle
                    initialValue: true,
                    // Icon, title, and switch for the tile
                    leading: const Icon(Icons.notifications),
                    title:
                        Text(AppLocalizations.of(context)!.pushNotifications),
                  ),
                  SettingsTile.switchTile(
                    // Callback function for when the toggle is switched
                    onToggle: (value) {},
                    // Initial value for the toggle
                    initialValue: true,
                    // Icon, title, and switch for the tile
                    leading: const Icon(Icons.mail_lock),
                    title: const Text('Email Notifications'),
                  ),
                ],
              ),
              SettingsSection(
                title: Text(AppLocalizations.of(context)!.accessibility),
                // Adding the tiles to the section
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.language),
                    title: Text(AppLocalizations.of(context)!.language),
                    value: const Text('English'),
                    onPressed: (e) => {
                      setState(() => {item = 2})
                    },
                  ),
                  // Switch tile for toggling push notifications
                  SettingsTile.switchTile(
                    // Callback function for when the toggle is switched
                    onToggle: (value) {},
                    // Initial value for the toggle
                    initialValue: true,
                    // Icon, title, and switch for the tile
                    leading: const Icon(Icons.text_decrease),
                    title: Text(AppLocalizations.of(context)!.largeText),
                  ),
                  SettingsTile.switchTile(
                    // Callback function for when the toggle is switched
                    onToggle: (value) {},
                    // Initial value for the toggle
                    initialValue: true,
                    // Icon, title, and switch for the tile
                    leading: const Icon(Icons.font_download),
                    title: Text(AppLocalizations.of(context)!.dyslexiaFont),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.theater_comedy),
                    title: Text(AppLocalizations.of(context)!.theme),
                    value: const Text('Default'),
                    onPressed: (e) => {
                      setState(() => {item = 3})
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: Text(AppLocalizations.of(context)!.helpSupport),
                // Adding the tiles to the section
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.format_quote),
                    title: Text(AppLocalizations.of(context)!.faq),
                  ),
                  // Switch tile for toggling push notifications
                  SettingsTile.navigation(
                    // Icon, title, and switch for the tile
                    leading: const Icon(Icons.support),
                    title: Text(AppLocalizations.of(context)!.contactSupport),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.info),
                    title: Text(AppLocalizations.of(context)!.aboutApp),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            // GestureDetector registers tap with the onTap callback function `outsidePressed()`
            onTap: () {
              outsidePressed();
            },
            child: item != 0
                ? Container(
                    // Semi-transparent overlay
                    color: const Color(0x20000000),
                    key: const Key("0"),
                  )
                : Container(key: const Key("1")),
          ),
          Center(
              // The Center widget has a height factor of 1.5 and a child widget of an OverlaySettings widget that receives the value of item as a parameter
              heightFactor: 1.5,
              child: OverlaySettings(item: item))
// The specific behavior of the `outsidePressed()` function and the `OverlaySettings` widget cannot be determined from this code snippet alone
        ]));
  }
}
