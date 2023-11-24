// Importing necessary packages and files
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:patinka/misc/navbar_provider.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:patinka/profile/settings/settings_overlays.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:patinka/swatch.dart';

import '../../api/config.dart';
import '../../api/token.dart';

// Creating an instance of SecureStorage for handling secure data storage
SecureStorage storage = SecureStorage();

// Settings widget
class Settings extends StatefulWidget {
  // Constructor for the Settings widget
  const Settings({super.key, required this.user});

  // User data passed to the widget
  final Map<String, dynamic>? user;

  // Creating the state for the Settings widget
  @override
  State<Settings> createState() => _Settings();
}

// Private class that represents the state of the Settings widget
class _Settings extends State<Settings> {
  // Instance of OverlaySettings for handling overlay UI elements
  OverlaySettings overlaySettings = OverlaySettings();

  // Default theme for the Settings UI
  SettingsThemeData defaultTheme = SettingsThemeData(
    settingsListBackground: Colors.transparent,
    titleTextColor: swatch[501],
    leadingIconsColor: swatch[601],
    settingsTileTextColor: swatch[601],
    tileDescriptionTextColor: swatch[901],
  );

  @override
  Widget build(BuildContext context) {
    // Hide the bottom navigation bar
    Provider.of<BottomBarVisibilityProvider>(context, listen: false).hide();

    // Building the UI of the Settings widget
    return PopScope(
      // Handle when the user navigates back
      onPopInvoked: (popped) {
        if (popped) {
          // Show the bottom navigation bar
          Provider.of<BottomBarVisibilityProvider>(context, listen: false)
              .show();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        extendBody: true,
        // AppBar widget for the title of the screen
        appBar: AppBar(
          iconTheme: IconThemeData(color: swatch[701]),
          elevation: 0,
          shadowColor: Colors.green.shade900,
          backgroundColor: Config.appbarColour,
          foregroundColor: Colors.transparent,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          // Setting the title of the AppBar
          title: Text(
            AppLocalizations.of(context)!.settings,
            style: TextStyle(color: swatch[701]),
          ),
        ),
        // Using the SettingsList widget from the settings_ui package
        body: Stack(
          children: [
            // Background overlay with blur and color filter
            Container(
              color: Colors.black.withOpacity(0.5),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 1,
                  sigmaY: 1,
                ),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Color.fromARGB(57, 54, 56, 43),
                    BlendMode.overlay,
                  ),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 126, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color.fromARGB(125, 0, 0, 0),
                ),
                margin: const EdgeInsets.all(8),
                child: SettingsList(
                  lightTheme: defaultTheme,
                  darkTheme: defaultTheme,
                  sections: [
                    // Section for security-related settings
                    SettingsSection(
                      title: Text(AppLocalizations.of(context)!.security),
                      tiles: <SettingsTile>[
                        // Navigation tile for email settings
                        SettingsTile.navigation(
                          leading: const Icon(Icons.mail),
                          title: Text(AppLocalizations.of(context)!.email),
                          value: Text(
                              widget.user?["email"] ?? "default@example.com"),
                        ),
                        // Navigation tile for password settings
                        SettingsTile.navigation(
                          leading: const Icon(Icons.password),
                          title: Text(AppLocalizations.of(context)!.password),
                          value: const Text('••••••••'),
                          onPressed: (e) => overlaySettings.password(context),
                        ),
                        // Switch tile for biometric settings
                        SettingsTile.switchTile(
                          activeSwitchColor: swatch[401],
                          onToggle: (value) {},
                          initialValue: true,
                          leading: const Icon(Icons.fingerprint),
                          title: Text(AppLocalizations.of(context)!.biometrics),
                        ),
                        // Navigation tile for logout
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
                    // Section for notification settings
                    SettingsSection(
                      title: Text(AppLocalizations.of(context)!.notifications),
                      tiles: <SettingsTile>[
                        // Switch tile for push notifications
                        SettingsTile.switchTile(
                          activeSwitchColor: swatch[401],
                          onToggle: (value) {},
                          initialValue: true,
                          leading: const Icon(Icons.notifications),
                          title: Text(
                              AppLocalizations.of(context)!.pushNotifications),
                        ),
                        // Switch tile for email notifications
                        SettingsTile.switchTile(
                          activeSwitchColor: swatch[401],
                          onToggle: (value) {},
                          initialValue: true,
                          leading: const Icon(Icons.mail_lock),
                          title: const Text('Email Notifications'),
                        ),
                      ],
                    ),
                    // Section for accessibility settings
                    SettingsSection(
                      title: Text(AppLocalizations.of(context)!.accessibility),
                      tiles: <SettingsTile>[
                        // Navigation tile for language settings
                        SettingsTile.navigation(
                          leading: const Icon(Icons.language),
                          title: Text(AppLocalizations.of(context)!.language),
                          value: const Text('English'),
                          onPressed: (e) => overlaySettings.languages(context),
                        ),
                        // Switch tile for large text settings
                        SettingsTile.switchTile(
                          activeSwitchColor: swatch[401],
                          onToggle: (value) {},
                          initialValue: true,
                          leading: const Icon(Icons.text_decrease),
                          title: Text(AppLocalizations.of(context)!.largeText),
                        ),
                        // Switch tile for dyslexia font settings
                        SettingsTile.switchTile(
                          activeSwitchColor: swatch[401],
                          onToggle: (value) {},
                          initialValue: true,
                          leading: const Icon(Icons.font_download),
                          title:
                              Text(AppLocalizations.of(context)!.dyslexiaFont),
                        ),
                        // Navigation tile for theme settings
                        SettingsTile.navigation(
                          leading: const Icon(Icons.theater_comedy),
                          title: Text(AppLocalizations.of(context)!.theme),
                          value: const Text('Default'),
                          onPressed: (e) => overlaySettings.theme(context),
                        ),
                      ],
                    ),
                    // Section for help and support settings
                    SettingsSection(
                      title: Text(AppLocalizations.of(context)!.helpSupport),
                      tiles: <SettingsTile>[
                        // Navigation tile for frequently asked questions
                        SettingsTile.navigation(
                          leading: const Icon(Icons.format_quote),
                          title: Text(AppLocalizations.of(context)!.faq),
                        ),
                        // Navigation tile for contacting support
                        SettingsTile.navigation(
                          leading: const Icon(Icons.support),
                          title: Text(
                              AppLocalizations.of(context)!.contactSupport),
                        ),
                        // Navigation tile for reporting a bug
                        SettingsTile.navigation(
                          leading: const Icon(Icons.bug_report),
                          title: const Text("Report a bug"),
                        ),
                        // Navigation tile for information about the app
                        SettingsTile.navigation(
                          leading: const Icon(Icons.info),
                          title: Text(AppLocalizations.of(context)!.aboutApp),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
