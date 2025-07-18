import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:http/http.dart";
import "package:patinka/api/config/config.dart";
import "package:patinka/api/image/image.dart";
import "package:patinka/api/social.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/l10n/app_localizations.dart";
import "package:patinka/misc/navbar_provider.dart";
import "package:patinka/services/navigation_service.dart";
import "package:patinka/swatch.dart";
import "package:provider/provider.dart";

// Define a widget for sending a post with an image
class SendPost extends StatefulWidget {
  const SendPost({required this.image, super.key});
  final Uint8List image;

  @override
  State<SendPost> createState() => _SendPost(); // Create state for widget
}

// Define the state for sending a post with an image
class _SendPost extends State<SendPost> {
  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  bool sending = false;

  // Override the existing build method to create the widget UI
  @override
  Widget build(final BuildContext context) {
    Provider.of<BottomBarVisibilityProvider>(context, listen: false)
        .hide(); // Hide The Navbar
    // Define a function to send the post information
    Future<String?> sendImage() async {
      try {
        if (!sending) {
          sending = true;

          // Upload the image file
          final StreamedResponse? response = await uploadFile(widget.image);
          final String? id = await response?.stream.bytesToString();
          if (id != null) {
            return id.substring(1, id.length - 1);
          }
          sending = false;
        }
        // Close the current screen and go back to the previous screen
      } catch (e) {
        // If there is an error, print the error message to the console
        commonLogger.e("An Error Occurred: $e");
      }
      return null;
    }

// Define a function named "sendInfo"
    void sendInfo() {
      try {
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

        // Call the "sendImage" function and wait for it to complete
        sendImage().then((final value) {
          if (value != null) {
            // Send post data to server
            SocialAPI.postPost(descriptionController.text, value)
                .then((final response) {
              // Ensure all pops are completed before changing navigator
              final navigatorState =
                  NavigationService.currentNavigatorKey.currentState;

              if (navigatorState != null) {
                navigatorState.popUntil((final route) => route.isFirst);
              }

              // Delay to ensure the previous pops are completed
              Future.delayed(Duration.zero, () {
                commonLogger.d("Showing Navbar");

                // Switch to the desired navigator index
                NavigationService.setCurrentIndex(0);
                // Send back to main page
                NavigationService.currentNavigatorKey.currentState!
                    .popUntil((final route) => route.isFirst);

                Future.delayed(const Duration(milliseconds: 250), () {
                  // Show the Bottom Navigation Bar after a short delay
                  Provider.of<BottomBarVisibilityProvider>(
                          NavigationService.navigatorKey(
                                  NavigationService.getCurrentIndex.toString())!
                              .currentContext!,
                          listen: false)
                      .show();
                });
              });
            });
          }
        });
      } catch (e) {
        commonLogger.e("Error creating post: $e");
      }
    }

    // Return the scaffold with the app bar and body
    return PopScope(
        canPop: true,
        onPopInvokedWithResult: (final bool didPop, final result) {},
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          extendBody: true,
          resizeToAvoidBottomInset:
              false, // Disables automatic resizing of the screen when the keyboard is opened.
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
            // Top bar of the page.
            leadingWidth: 48, // Adjusts the width of the leading widget.
            centerTitle: false, // Aligns the title to the left.
            title: Title(
              title: AppLocalizations.of(context)!
                  .createPost, // Sets the title of the app bar.
              color: const Color(0xFFDDDDDD), // Sets the color of the title.
              child: Text(
                AppLocalizations.of(context)!.createPost,
                style: TextStyle(color: swatch[701]),
              ), // The actual text of the title.
            ),
            actions: [
              TextButton(
                  onPressed: sendInfo,
                  child: Text(
                    AppLocalizations.of(context)!.send,
                    style: TextStyle(
                        color: swatch[901],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.3),
                  )) // A button to send the post.
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(color: Color(0x58000000)),
            padding: const EdgeInsets.symmetric(
                vertical: 128,
                horizontal: 48), // Adds padding to the entire body.
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Aligns the children to the left.
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(
                        0xaa000000), // Sets the background color of the container.
                  ),
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          AppLocalizations.of(context)!.postDescription,
                          style: TextStyle(color: swatch[601]),
                        ),
                      ),
                      TextField(
                        controller: descriptionController,
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
                        cursorColor: swatch[801],
                        style: TextStyle(color: swatch[801]),
                      ),
                    ],
                  ),
                ),
                Expanded(child: Center(child: Image.memory(widget.image)))
              ],
            ),
          ),
        ));
  }
}
