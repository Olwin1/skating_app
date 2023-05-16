import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:skating_app/swatch.dart';

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
        body: Stack(children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image:
                          const AssetImage("assets/backgrounds/graffiti.png"),
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomLeft,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.5), BlendMode.srcOver)),
                ),
                padding: const EdgeInsets.all(16)),
          ),
          Container(
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
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color.fromARGB(125, 0, 0, 0),
                  ),
                  child:
                      // Second column with display name
                      Column(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                              top: 8), // Add padding above text
                          child: Text(AppLocalizations.of(context)!.displayName,
                              style: TextStyle(color: swatch[601])),
                        ),
                        TextField(
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: swatch[200]!),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: swatch[401]!),
                            ),
                          ),
                          cursorColor: swatch[601],
                          style: TextStyle(color: swatch[601]),
                          // Remove default padding
                        ),
                      ],
                    ),
                    // Third column with username
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                              top: 8), // Add padding above text
                          child: Text(AppLocalizations.of(context)!.username,
                              style: TextStyle(color: swatch[601])),
                        ),
                        TextField(
                          // Remove default padding
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: swatch[200]!),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: swatch[401]!),
                            ),
                          ),
                          cursorColor: swatch[601],
                          style: TextStyle(color: swatch[601]),
                        ),
                      ],
                    ),
                    // Fourth column with country
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(AppLocalizations.of(context)!.country,
                              style: TextStyle(color: swatch[601])),
                        ),
                        TextField(
                          // Remove default padding
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: swatch[200]!),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: swatch[401]!),
                            ),
                          ),
                          cursorColor: swatch[601],
                          style: TextStyle(color: swatch[601]),
                        ),
                      ],
                    ),
                    // Fifth column with about me
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            AppLocalizations.of(context)!.aboutMe,
                            style: TextStyle(color: swatch[601]),
                          ),
                        ),
                        TextField(
                          // Remove default padding
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: swatch[200]!),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: swatch[401]!),
                            ),
                          ),
                          cursorColor: swatch[601],
                          style: TextStyle(color: swatch[601]),
                        ),
                      ],
                    )
                  ]))
            ]),
          ),
        ]));
  }
}
