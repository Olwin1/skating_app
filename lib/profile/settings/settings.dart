// Importing necessary packages and files
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:patinka/profile/settings/settings_overlays.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:patinka/swatch.dart';

import '../../api/token.dart';

SecureStorage storage = SecureStorage();

// Settings widget
class Settings extends StatefulWidget {
  const Settings({Key? key, required this.user}) : super(key: key);
  final Map<String, dynamic>? user;
  @override
  State<Settings> createState() => _Settings();
}

// Private class that represents the state of the Settings widget
class _Settings extends State<Settings> {
  OverlaySettings overlaySettings = OverlaySettings();
  // When outside pressed set item state to hide overlay
  SettingsThemeData defaultTheme = SettingsThemeData(
      settingsListBackground: Colors.transparent,
      titleTextColor: swatch[501],
      leadingIconsColor: swatch[601],
      settingsTileTextColor: swatch[601],
      tileDescriptionTextColor: swatch[901]);

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
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: const AssetImage("assets/backgrounds/graffiti.png"),
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomLeft,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5), BlendMode.color)),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color.fromARGB(125, 0, 0, 0),
            ),
            margin: const EdgeInsets.all(8),
            child: SettingsList(
              lightTheme: defaultTheme,
              darkTheme: defaultTheme,
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
                      value:
                          Text(widget.user?["email"] ?? "default@example.com"),
                    ),
                    // Navigation tile with a language icon, title, and value
                    SettingsTile.navigation(
                      leading: const Icon(Icons.password),
                      title: Text(AppLocalizations.of(context)!.password),
                      value: const Text('••••••••'),
                      onPressed: (e) => overlaySettings.password(context),
                    ),
                    // Switch tile for toggling push notifications
                    SettingsTile.switchTile(
                      activeSwitchColor: swatch[401],
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
                      onPressed: (e) => {
                        // Remove stored tokens and restart app
                        storage
                            .logout()
                            .then((value) => Phoenix.rebirth(context))
                      },
                    ),
                  ],
                ),
                SettingsSection(
                  title: Text(AppLocalizations.of(context)!.notifications),
                  // Adding the tiles to the section
                  tiles: <SettingsTile>[
                    // Switch tile for toggling push notifications
                    SettingsTile.switchTile(
                      activeSwitchColor: swatch[401],
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
                      activeSwitchColor: swatch[401],
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
                      onPressed: (e) => overlaySettings.languages(context),
                    ),
                    // Switch tile for toggling push notifications
                    SettingsTile.switchTile(
                      activeSwitchColor: swatch[401],
                      // Callback function for when the toggle is switched
                      onToggle: (value) {},
                      // Initial value for the toggle
                      initialValue: true,
                      // Icon, title, and switch for the tile
                      leading: const Icon(Icons.text_decrease),
                      title: Text(AppLocalizations.of(context)!.largeText),
                    ),
                    SettingsTile.switchTile(
                      activeSwitchColor: swatch[401],
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
                      onPressed: (e) => overlaySettings.theme(context),
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
          ),
// The specific behavior of the `outsidePressed()` function and the `OverlaySettings` widget cannot be determined from this code snippet alone
        ]));
  }
}
