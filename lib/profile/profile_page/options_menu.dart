import 'package:flutter/material.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/profile/edit_profile.dart';
import 'package:patinka/profile/profile_page/profile_page.dart';
import 'package:patinka/profile/saved_posts.dart';
import 'package:patinka/profile/settings/settings.dart';
import 'package:patinka/swatch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OptionsMenu extends StatefulWidget {
  final Map<String, dynamic>? user;

  // StatefulWidget that defines an options menu
  const OptionsMenu({super.key, required this.user});

  @override
  State<OptionsMenu> createState() => _OptionsMenuState();
}

class _OptionsMenuState extends State<OptionsMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DropdownPage>(
      color: const Color(0x66000000),
      icon: Icon(
        Icons.more_vert,
        color: swatch[601],
      ),
      // Offset to set the position of the menu relative to the button
      offset: const Offset(0, 64),
      // Callback function that will be called when a menu item is selected
      onSelected: (DropdownPage item) {
        // In this case, it just prints "selected" to the console
        commonLogger.i("selected");
        if (item == DropdownPage.editProfile) {
          // If item pressed is Edit Profile
          Navigator.push(
            // Send to edit profile page
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  EditProfile(
                user: widget.user,
              ),
              opaque: false,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = 0.0;
                const end = 1.0;
                var tween = Tween(begin: begin, end: end);
                var fadeAnimation = tween.animate(animation);
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
              pageBuilder: (context, animation, secondaryAnimation) =>
                  Settings(user: widget.user),
              opaque: false,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = 0.0;
                const end = 1.0;
                var tween = Tween(begin: begin, end: end);
                var fadeAnimation = tween.animate(animation);
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
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const SavedPosts(),
              opaque: false,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = 0.0;
                const end = 1.0;
                var tween = Tween(begin: begin, end: end);
                var fadeAnimation = tween.animate(animation);
                return FadeTransition(
                  opacity: fadeAnimation,
                  child: child,
                );
              },
            ),
          );
        }
      },
      // Define the items in the menu using PopupMenuItem widgets
      itemBuilder: (BuildContext context) => <PopupMenuEntry<DropdownPage>>[
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
      ],
    );
  }
}
