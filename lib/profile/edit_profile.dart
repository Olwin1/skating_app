import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Define the EditProfile widget which extends StatefulWidget
class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);
  // title is a required parameter

  @override
  // Create the state for the EditProfile widget
  State<EditProfile> createState() => _EditProfile();
}

// Define the state for the EditProfile widget
class _EditProfile extends State<EditProfile> {
  @override
  // Build the UI for the EditProfile widget
  Widget build(BuildContext context) {
    return Scaffold(
      // Define an app bar with a title "Edit Profile"
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editProfile),
      ),
      // Define the body of the Scaffold
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // First column with an avatar and an edit picture button
          Column(
            children: [
              // Display the avatar
              const CircleAvatar(
                radius: 36,
                backgroundImage: AssetImage("assets/placeholders/150.png"),
              ),
              // Display the edit picture button
              TextButton(
                  onPressed: () => print("pressed"),
                  child: Text(AppLocalizations.of(context)!.editPicture))
            ],
          ),
          // Second column with display name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(top: 8), // Add padding above text
                child: Text(AppLocalizations.of(context)!.displayName),
              ),
              const TextField(
                // Remove default padding
                decoration: InputDecoration(
                    isDense: true, contentPadding: EdgeInsets.zero),
              ),
            ],
          ),
          // Third column with username
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(top: 8), // Add padding above text
                child: Text(AppLocalizations.of(context)!.username),
              ),
              const TextField(
                // Remove default padding
                decoration: InputDecoration(
                    isDense: true, contentPadding: EdgeInsets.zero),
              ),
            ],
          ),
          // Fourth column with country
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(AppLocalizations.of(context)!.country),
              ),
              const TextField(
                // Remove default padding
                decoration: InputDecoration(
                    isDense: true, contentPadding: EdgeInsets.zero),
              ),
            ],
          ),
          // Fifth column with about me
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(AppLocalizations.of(context)!.aboutMe),
              ),
              const TextField(
                // Remove default padding
                decoration: InputDecoration(
                    isDense: true, contentPadding: EdgeInsets.zero),
              ),
            ],
          )
        ]),
      ),
    );
  }
}
