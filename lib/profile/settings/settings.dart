// Importing necessary packages and files
import 'package:flutter/material.dart';
import 'package:skating_app/objects/user.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:skating_app/profile/settings/settings_overlays.dart';

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
    // Creating a user object with the ID of 1
    User user = User("1");

    // Building the UI of the Settings widget
    return Scaffold(
        // AppBar widget for the title of the screen
        appBar: AppBar(
          // Setting the title of the AppBar
          title: const Text("Settings"),
        ),
        // Using the SettingsList widget from the settings_ui package
        body: Stack(children: [
          SettingsList(
            sections: [
              // Adding a SettingsSection to group related tiles together
              SettingsSection(
                title: const Text("Security"),
                // Adding the tiles to the section
                tiles: <SettingsTile>[
                  // Navigation tile with an email icon, title, and value
                  SettingsTile.navigation(
                    leading: const Icon(Icons.mail),
                    title: const Text("Email"),
                    value: const Text("default@example.com"),
                  ),
                  // Navigation tile with a language icon, title, and value
                  SettingsTile.navigation(
                    leading: const Icon(Icons.password),
                    title: const Text('Password'),
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
                    title: const Text('Biometric Verification'),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                  ),
                ],
              ),
              SettingsSection(
                title: const Text("Notifications"),
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
                    title: const Text('Push Notifications'),
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
                title: const Text("Accessibility"),
                // Adding the tiles to the section
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
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
                    title: const Text('Large Text'),
                  ),
                  SettingsTile.switchTile(
                    // Callback function for when the toggle is switched
                    onToggle: (value) {},
                    // Initial value for the toggle
                    initialValue: true,
                    // Icon, title, and switch for the tile
                    leading: const Icon(Icons.font_download),
                    title: const Text('Dyslexia Font'),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.theater_comedy),
                    title: const Text('Theme'),
                    value: const Text('Default'),
                    onPressed: (e) => {
                      setState(() => {item = 3})
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: const Text("Help & Support"),
                // Adding the tiles to the section
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.format_quote),
                    title: const Text('FAQ'),
                  ),
                  // Switch tile for toggling push notifications
                  SettingsTile.navigation(
                    // Icon, title, and switch for the tile
                    leading: const Icon(Icons.support),
                    title: const Text('Contact Support'),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.info),
                    title: const Text('About App'),
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
