import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/api/social.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/profile/upload_avatar.dart';
import 'package:patinka/swatch.dart';

import '../api/config.dart';

// Define the EditProfile widget which extends StatefulWidget
class EditProfile extends StatefulWidget {
  final Map<String, dynamic>? user;

  const EditProfile({Key? key, required this.user}) : super(key: key);
  // title is a required parameter

  @override
  // Create the state for the EditProfile widget
  State<EditProfile> createState() => _EditProfile();
}

// Define the state for the EditProfile widget
class _EditProfile extends State<EditProfile> {
  TextEditingController displayNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController aboutMeController = TextEditingController();
  @override
  void initState() {
    usernameController.value = TextEditingValue(
        text: widget.user == null || widget.user!["username"] == null
            ? ""
            : widget.user!["username"]);
    aboutMeController.value = TextEditingValue(
        text: widget.user == null || widget.user!["description"] == null
            ? ""
            : widget.user!["description"]);

    super.initState();
  }

  Future<bool> _onWillPop() async {
    if (aboutMeController.text == widget.user?["description"]) {
      return true;
    }
    showDialog(
      useRootNavigator: false,
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: swatch[800],
          title: Text(
            'Processing',
            style: TextStyle(color: swatch[701]),
          ),
          content: Text(
            'Please wait...',
            style: TextStyle(color: swatch[901]),
          ),
        );
      },
    );
    await SocialAPI.setDescription(aboutMeController.text);

    // Pop the dialog
    if (mounted) {
      Navigator.of(context).pop();
    }
    // Return 'true' to allow the user to navigate back
    return true;
  }

  void showCountries() {
    // Show the country picker dialog
    showCountryPicker(
      context: context, // The current build context
      useSafeArea:
          true, // Ensure the picker is displayed within the safe area of the screen
      onSelect: (Country country) {
        // Callback function when a country is selected
        commonLogger.v('Select country: ${country.displayName}');
        countryController.text = country.name;
      },
      countryListTheme: CountryListThemeData(
        inputDecoration: InputDecoration(
          filled: true,
          fillColor: swatch[800], // Set the fill color of the input field
          focusColor:
              swatch[401], // Set the color when the input field is focused
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: swatch[
                    200]!), // Set the border color when the input field is enabled
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: swatch[
                    201]!), // Set the border color when the input field is focused
          ),
        ),
        searchTextStyle:
            TextStyle(color: swatch[701]), // Set the color of the search text
        padding: const EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16), // Set the padding of the country list
        margin: const EdgeInsets.only(
            top: 16, left: 16, right: 16), // Set the margin of the country list
        backgroundColor: const Color(
            0xae000000), // Set the background color of the country list
        textStyle: TextStyle(
            color: swatch[801]), // Set the text color of the country names
      ),
    );
  }

  @override
  // Build the UI for the EditProfile widget
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
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
                          image: const AssetImage(
                              "assets/backgrounds/graffiti.png"),
                          fit: BoxFit.cover,
                          alignment: Alignment.bottomLeft,
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.5),
                              BlendMode.srcOver)),
                    ),
                    padding: const EdgeInsets.all(16)),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: ListView(children: [
                  // First column with an avatar and an edit picture button
                  Column(
                    children: [
                      // Display the avatar
                      (widget.user == null || widget.user!["avatar_id"] == null)
                          ? Shimmer.fromColors(
                              baseColor: shimmer["base"]!,
                              highlightColor: shimmer["highlight"]!,
                              child: CircleAvatar(
                                // Create a circular avatar icon
                                radius: 36, // Set radius to 36
                                backgroundColor: swatch[900],
                              ))
                          : widget.user?["avatar_id"] != "default"
                              ? CachedNetworkImage(
                                  imageUrl:
                                      '${Config.uri}/image/thumbnail/${widget.user!["avatar_id"]}',
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    height: 72,
                                    width: 72,
                                    decoration: BoxDecoration(
                                      shape: BoxShape
                                          .circle, // Set the shape of the container to a circle
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                )
                              : CircleAvatar(
                                  foregroundImage:
                                      const AssetImage("assets/icons/hand.png"),
                                  // Create a circular avatar icon
                                  radius: 36, // Set radius to 36
                                  backgroundColor: swatch[900],
                                ),
                      // Display the edit picture button
                      TextButton(
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true).push(
                                  // Root navigator hides navbar
                                  // Send to Save Session page
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ChangeAvatarPage())),
                          child:
                              Text(AppLocalizations.of(context)!.editPicture))
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
                              child: Text(
                                  AppLocalizations.of(context)!.displayName,
                                  style: TextStyle(color: swatch[601])),
                            ),
                            TextField(
                              readOnly: true,
                              controller: displayNameController,
                              maxLength: 30,
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
                              child: Text(
                                  AppLocalizations.of(context)!.username,
                                  style: TextStyle(color: swatch[601])),
                            ),
                            TextField(
                              readOnly: true,
                              controller: usernameController,
                              maxLength: 30,
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
                              //onTap: () => showCountries(),
                              controller: countryController,

                              readOnly: true,
                              maxLength: 56,
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
                              controller: aboutMeController,
                              maxLines: 5,
                              maxLength: 150,
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
            ])));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
