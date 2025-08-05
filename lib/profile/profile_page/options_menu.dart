import "package:flutter/material.dart";
import "package:patinka/api/support.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/l10n/app_localizations.dart";
import "package:patinka/profile/edit_profile/edit_profile.dart";
import "package:patinka/profile/profile_page/profile_page.dart";
import "package:patinka/profile/saved_posts.dart";
import "package:patinka/profile/settings/settings.dart";
import "package:patinka/swatch.dart";

class OptionsMenu extends StatefulWidget {
  // StatefulWidget that defines an options menu
  const OptionsMenu({required this.user, required this.isSelf, super.key});
  final Map<String, dynamic>? user;
  final bool isSelf;

  @override
  State<OptionsMenu> createState() => _OptionsMenuState();
}

class _OptionsMenuState extends State<OptionsMenu> {
  @override
  Widget build(final BuildContext context) => PopupMenuButton<DropdownPage>(
        color: const Color(0x66000000),
        icon: Icon(
          Icons.more_vert,
          color: swatch[601],
        ),
        // Offset to set the position of the menu relative to the button
        offset: const Offset(0, 64),
        // Callback function that will be called when a menu item is selected
        onSelected: (final DropdownPage item) {
          // In this case, it just prints "selected" to the console
          commonLogger.i("selected");
          if (item == DropdownPage.editProfile) {
            // If item pressed is Edit Profile
            Navigator.push(
              // Send to edit profile page
              context,
              PageRouteBuilder(
                pageBuilder: (final context, final animation,
                        final secondaryAnimation) =>
                    EditProfile(
                  user: widget.user,
                ),
                opaque: false,
                transitionsBuilder: (final context, final animation,
                    final secondaryAnimation, final child) {
                  const begin = 0.0;
                  const end = 1.0;
                  final tween = Tween(begin: begin, end: end);
                  final fadeAnimation = tween.animate(animation);
                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: child,
                  );
                },
              ),
            );
          }
          if (item == DropdownPage.settings) {
            // If item pressed is Settings
            Navigator.push(
              // Send to settings page
              context,
              PageRouteBuilder(
                pageBuilder: (final context, final animation,
                        final secondaryAnimation) =>
                    Settings(user: widget.user),
                opaque: false,
                transitionsBuilder: (final context, final animation,
                    final secondaryAnimation, final child) {
                  const begin = 0.0;
                  const end = 1.0;
                  final tween = Tween(begin: begin, end: end);
                  final fadeAnimation = tween.animate(animation);
                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: child,
                  );
                },
              ),
            );
          }
          if (item == DropdownPage.saved) {
            // If item pressed is Settings
            Navigator.push(
              // Send to settings page
              context,
              PageRouteBuilder(
                pageBuilder: (final context, final animation,
                        final secondaryAnimation) =>
                    const SavedPosts(),
                opaque: false,
                transitionsBuilder: (final context, final animation,
                    final secondaryAnimation, final child) {
                  const begin = 0.0;
                  const end = 1.0;
                  final tween = Tween(begin: begin, end: end);
                  final fadeAnimation = tween.animate(animation);
                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: child,
                  );
                },
              ),
            );
          }
          if (item == DropdownPage.blockUser || item == DropdownPage.unblockUser) {
            if (widget.user != null) {
              // Return to homepage and set to default route
              Navigator.popUntil(context, (final route) => route.isFirst);
              
              if(item == DropdownPage.blockUser) {
                SupportAPI.postBlockUser(widget.user!["user_id"]);
              } else {
                SupportAPI.postUnblockUser(widget.user!["user_id"]);
              }
            }
          }
        },
        // Define the items in the menu using PopupMenuItem widgets
        itemBuilder: (final BuildContext context) => widget.isSelf
            ? <PopupMenuEntry<DropdownPage>>[
                // First menu item
                PopupMenuItem<DropdownPage>(
                  // Value of the menu item, an instance of the DropdownPage enumeration
                  value: DropdownPage.editProfile,
                  // Text widget that displays the text for the menu item
                  child: Text(AppLocalizations.of(context)!.editProfile,
                      style: TextStyle(color: swatch[801])),
                ),
                // Second menu item
                PopupMenuItem<DropdownPage>(
                  // Value of the menu item, an instance of the DropdownPage enumeration
                  value: DropdownPage.settings,
                  // Text widget that displays the text for the menu item
                  child: Text(AppLocalizations.of(context)!.settings,
                      style: TextStyle(color: swatch[801])),
                ),
                // Third menu item
                PopupMenuItem<DropdownPage>(
                  // Value of the menu item, an instance of the DropdownPage enumeration
                  value: DropdownPage.saved,
                  // Text widget that displays the text for the menu item
                  child: Text(AppLocalizations.of(context)!.saved,
                      style: TextStyle(color: swatch[801])),
                ),
              ]
            : <PopupMenuEntry<DropdownPage>>[
                PopupMenuItem<DropdownPage>(
                  // Value of the menu item, an instance of the DropdownPage enumeration
                  value: widget.user?["blocked"]?DropdownPage.unblockUser:DropdownPage.blockUser,
                  // Text widget that displays the text for the menu item
                  child: Text(widget.user?["blocked"]?"Unblock":"Block",
                      style: TextStyle(color: Colors.red.shade700)),
                ),
              ],
      );
}
