import "dart:ui";

import "package:cached_network_image/cached_network_image.dart";
import "package:country_picker/country_picker.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:flutter/services.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:patinka/api/config.dart";
import "package:patinka/api/social.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/misc/default_profile.dart";
import "package:patinka/profile/upload_avatar.dart";
import "package:patinka/swatch.dart";
import "package:shimmer/shimmer.dart";

// Define the EditProfile widget which extends StatefulWidget
class EditProfile extends StatefulWidget {

  const EditProfile({required this.user, super.key});
  final Map<String, dynamic>? user;
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

  Future<bool> _onWillPop(final bool didPop) async {
    if (didPop) {
      String? previousText = widget.user?["description"];
      previousText ??= "";
      if (aboutMeController.text == previousText) {
        return true;
      }
      SchedulerBinding.instance.addPostFrameCallback((final _) async {
        showDialog(
          useRootNavigator: false,
          context: context,
          barrierDismissible: false,
          builder: (final BuildContext context) => AlertDialog(
              backgroundColor: swatch[800],
              title: Text(
                "Processing",
                style: TextStyle(color: swatch[701]),
              ),
              content: Text(
                "Please wait...",
                style: TextStyle(color: swatch[901]),
              ),
            ),
        );
        await SocialAPI.setDescription(aboutMeController.text);

        // Pop the dialog
        if (mounted) {
          commonLogger.d("Popping Processing Message");
          Navigator.of(context).pop();
        }
      });

      // Return 'true' to allow the user to navigate back
      return true;
    }
    return false;
  }

  void showCountries() {
    // Show the country picker dialog
    showCountryPicker(
      context: context, // The current build context
      useSafeArea:
          true, // Ensure the picker is displayed within the safe area of the screen
      onSelect: (final Country country) {
        // Callback function when a country is selected
        commonLogger.t("Select country: ${country.displayName}");
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
  Widget build(final BuildContext context) => PopScope(
        canPop: true,
        onPopInvokedWithResult: (final bool didPop, final result) => _onWillPop(didPop),
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
              ColoredBox(
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
                                  imageBuilder: (final context, final imageProvider) =>
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
                                  pageBuilder: (final context, final animation,
                                          final secondaryAnimation) =>
                                      const ChangeAvatarPage(),
                                  opaque: false,
                                  transitionsBuilder: (final context, final animation,
                                      final secondaryAnimation, final child) {
                                    const begin = 0.0;
                                    const end = 1.0;
                                    final tween = Tween(begin: begin, end: end);
                                    final fadeAnimation =
                                        tween.animate(animation);
                                    return FadeTransition(
                                      opacity: fadeAnimation,
                                      child: child,
                                    );
                                  },
                                ),
                              ),
                          child: Text(
                            AppLocalizations.of(context)!.editPicture,
                            style: TextStyle(color: swatch[100]),
                          ))
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
                                counterStyle: TextStyle(color: swatch[100]),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: swatch[200]!),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: swatch[401]!),
                                ),
                              ),
                              cursorColor: swatch[801],
                              style: TextStyle(color: swatch[801]),
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
                                counterStyle: TextStyle(color: swatch[100]),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: swatch[200]!),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: swatch[401]!),
                                ),
                              ),
                              cursorColor: swatch[801],
                              style: TextStyle(color: swatch[801]),
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
                                counterText: "",
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: swatch[200]!),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: swatch[401]!),
                                ),
                              ),
                              cursorColor: swatch[801],
                              style: TextStyle(color: swatch[801]),
                            ),
                            const SizedBox(
                              height: 18,
                            )
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
                                counterStyle: TextStyle(color: swatch[100]),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: swatch[200]!),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: swatch[401]!),
                                ),
                              ),
                              cursorColor: swatch[801],
                              style: TextStyle(color: swatch[801]),
                            ),
                          ],
                        )
                      ]))
                ]),
              ),
            ])));

  @override
  void dispose() {
    super.dispose();
  }
}
