// Importing necessary packages and files
import "dart:ui";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:flutter_phoenix/flutter_phoenix.dart";
import "package:patinka/api/config/config.dart";
import "package:patinka/api/token.dart";
import "package:patinka/misc/navbar_provider.dart";
import "package:patinka/profile/settings/blocked_users.dart";
import "package:patinka/profile/settings/list_type.dart";
import "package:patinka/profile/settings/report_list.dart";
import "package:patinka/profile/settings/settings_overlays.dart";
import "package:patinka/profile/settings/support_list.dart";
import "package:patinka/swatch.dart";
import "package:provider/provider.dart";
import "package:settings_ui/settings_ui.dart";

// Creating an instance of SecureStorage for handling secure data storage
SecureStorage storage = SecureStorage();

// Settings widget
class Settings extends StatefulWidget {
  // Constructor for the Settings widget
  const Settings({required this.user, super.key});

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
  Widget build(final BuildContext context) {
    // Hide the bottom navigation bar
    Provider.of<BottomBarVisibilityProvider>(context, listen: false).hide();

    // Building the UI of the Settings widget
    return PopScope(
      // Handle when the user navigates back
      onPopInvokedWithResult: (final popped, final result) {
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
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.5),
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
                      title: const Text("Alpha"),
                      tiles: <SettingsTile>[
                        // Navigation tile for email settings
                        SettingsTile.navigation(
                          leading: const Icon(Icons.next_plan_outlined),
                          title: Text(
                              AppLocalizations.of(context)!.plannedFeatures),
                          onPressed: (final e) =>
                              {overlaySettings.features(context)},
                        ),
                        SettingsTile.navigation(
                          leading: const Icon(Icons.egg_alt_rounded),
                          title: Text(
                              AppLocalizations.of(context)!.suggestFeature),
                          onPressed: (final context) {
                            Navigator.of(context).push(
                                // Send to signal info page
                                MaterialPageRoute(
                                    builder: (final context) => SupportList(
                                          type: SupportListType.suggestion,
                                          user: widget.user,
                                        )));
                          },
                        ),
                      ],
                    ),
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
                          enabled: false,
                        ),
                        SettingsTile.navigation(
                          leading: const Icon(Icons.block),
                          title:
                              Text(AppLocalizations.of(context)!.blockedUsers),
                          onPressed: (final context) {
                            Navigator.of(context).push(
                                // Send to blocked user list page
                                MaterialPageRoute(
                                    builder: (final context) =>
                                        const BlockedUsersList()));
                          },
                          enabled: true,
                        ),
                        // Navigation tile for password settings
                        SettingsTile.navigation(
                          leading: const Icon(Icons.password),
                          title: Text(AppLocalizations.of(context)!.password),
                          value: const Text("••••••••"),
                          onPressed: (final e) =>
                              overlaySettings.password(context),
                          enabled: false,
                        ),
                        // Switch tile for biometric settings
                        SettingsTile.switchTile(
                          activeSwitchColor: swatch[401],
                          onToggle: (final value) {},
                          initialValue: true,
                          leading: const Icon(Icons.fingerprint),
                          title: Text(AppLocalizations.of(context)!.biometrics),
                          enabled: false,
                        ),
                        // Navigation tile for logout
                        SettingsTile.navigation(
                          leading: const Icon(Icons.logout),
                          title: Text(AppLocalizations.of(context)!.logout),
                          onPressed: (final e) => {
                            // Remove stored tokens and restart app
                            storage.logout().then((final value) => {
                                  if (context.mounted)
                                    {Phoenix.rebirth(context)}
                                })
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
                          onToggle: (final value) {},
                          initialValue: true,
                          leading: const Icon(Icons.notifications),
                          title: Text(
                              AppLocalizations.of(context)!.pushNotifications),
                          enabled: false,
                        ),
                        // Switch tile for email notifications
                        SettingsTile.switchTile(
                          activeSwitchColor: swatch[401],
                          onToggle: (final value) {},
                          initialValue: true,
                          leading: const Icon(Icons.mail_lock),
                          title: Text(
                              AppLocalizations.of(context)!.emailNotifications),
                          enabled: false,
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
                          value: const Text("English"),
                          onPressed: (final e) =>
                              overlaySettings.languages(context),
                          enabled: false,
                        ),
                        // Switch tile for large text settings
                        SettingsTile.switchTile(
                          activeSwitchColor: swatch[401],
                          onToggle: (final value) {},
                          initialValue: true,
                          leading: const Icon(Icons.text_decrease),
                          title: Text(AppLocalizations.of(context)!.largeText),
                          enabled: false,
                        ),
                        // Switch tile for dyslexia font settings
                        SettingsTile.switchTile(
                          activeSwitchColor: swatch[401],
                          onToggle: (final value) {},
                          initialValue: true,
                          leading: const Icon(Icons.font_download),
                          title:
                              Text(AppLocalizations.of(context)!.dyslexiaFont),
                          enabled: false,
                        ),
                        // Navigation tile for theme settings
                        SettingsTile.navigation(
                          leading: const Icon(Icons.theater_comedy),
                          title: Text(AppLocalizations.of(context)!.theme),
                          value:
                              Text(AppLocalizations.of(context)!.systemDefault),
                          onPressed: (final e) =>
                              overlaySettings.theme(context),
                          enabled: false,
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
                          enabled: false,
                          onPressed: (final context) {
                            Navigator.of(context).push(
                                // Send to signal info page
                                MaterialPageRoute(
                                    builder: (final context) => SupportList(
                                          type: SupportListType.support,
                                          user: widget.user,
                                        )));
                          },
                        ),
                        // Navigation tile for contacting support
                        SettingsTile.navigation(
                            leading: const Icon(Icons.support),
                            title: Text(
                                AppLocalizations.of(context)!.contactSupport),
                            onPressed: (final context) {
                              Navigator.of(context).push(
                                  // Send to signal info page
                                  MaterialPageRoute(
                                      builder: (final context) => SupportList(
                                            type: SupportListType.support,
                                            user: widget.user,
                                          )));
                            }),

                        // Navigation tile for support staff to see reports
                        // If the user is not a moderator or an admin then just don't display this section
                        if (widget.user!["user_role"] == "moderator" ||
                            widget.user!["user_role"] == "administrator")
                          SettingsTile.navigation(
                              leading: const Icon(Icons.policy),
                              title: Text(
                                  AppLocalizations.of(context)!.reviewReports),
                              onPressed: (final context) {
                                Navigator.of(context).push(
                                    // Send to signal info page
                                    MaterialPageRoute(
                                        builder: (final context) => ReportList(
                                              user: widget.user,
                                              isSelf: false,
                                            )));
                              }),
                        SettingsTile.navigation(
                            leading: const Icon(Icons.policy),
                            title:
                                Text(AppLocalizations.of(context)!.myReports),
                            onPressed: (final context) {
                              Navigator.of(context).push(
                                  // Send to signal info page
                                  MaterialPageRoute(
                                      builder: (final context) => ReportList(
                                            user: widget.user,
                                            isSelf: true,
                                          )));
                            }),

                        // Navigation tile for reporting a bug
                        SettingsTile.navigation(
                          leading: const Icon(Icons.bug_report),
                          title: Text(AppLocalizations.of(context)!.reportBug),
                          onPressed: (final context) {
                            Navigator.of(context).push(
                                // Send to signal info page
                                MaterialPageRoute(
                                    builder: (final context) => SupportList(
                                          type: SupportListType.bug,
                                          user: widget.user,
                                        )));
                          },
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
