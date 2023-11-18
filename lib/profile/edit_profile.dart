import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/api/social.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/profile/upload_avatar.dart';
import 'package:patinka/swatch.dart';

import '../api/config.dart';
import '../misc/default_profile.dart';

// Define the EditProfile widget which extends StatefulWidget
class EditProfile extends StatefulWidget {
  final Map<String, dynamic>? user;

  const EditProfile({super.key, required this.user});
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
        commonLogger.t('Select country: ${country.displayName}');
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
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            extendBodyBehindAppBar: true,
            extendBody: true,
            // Define an app bar with a title "Edit Profile"
            appBar: AppBar(
              iconTheme: IconThemeData(color: swatch[701]),
              elevation: 0,
              shadowColor: Colors.green.shade900,
              backgroundColor: const Color(0x24000000),
              foregroundColor: Colors.transparent,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              ),
              title: Text(
                AppLocalizations.of(context)!.editProfile,
                style: TextStyle(color: swatch[701]),
              ),
            ),
            // Define the body of the Scaffold
            body: Stack(fit: StackFit.expand, children: [
              Container(
                color: Colors.black
                    .withOpacity(0.5), // Adjust the opacity as needed
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 1,
                      sigmaY: 1), // Adjust the sigma values for more/less blur
                  child: Container(
                    color: Colors.transparent, // Use a transparent color
                  ),
                ),
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
                              : const DefaultProfile(radius: 36),
                      // Display the edit picture button
                      TextButton(
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true).push(
                                // Root navigator hides navbar
                                // Send to Save Session page
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      const ChangeAvatarPage(),
                                  opaque: false,
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin = 0.0;
                                    const end = 1.0;
                                    var tween = Tween(begin: begin, end: end);
                                    var fadeAnimation =
                                        tween.animate(animation);
                                    return FadeTransition(
                                      opacity: fadeAnimation,
                                      child: child,
                                    );
                                  },
                                ),
                              ),
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
