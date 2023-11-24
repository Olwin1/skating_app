// Import necessary packages and files
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/common_logger.dart';

// Import custom components and configurations
import '../../misc/default_profile.dart';
import '../../swatch.dart';
import '../../api/config.dart';
import 'private_message.dart';

// SuggestionListWidget class creates a stateful widget that displays a list of user suggestions
class SuggestionListWidget extends StatefulWidget {
  // Constructor for SuggestionListWidget
  const SuggestionListWidget({
    super.key,
    required this.user,
    required this.callback,
  });

  // Properties for user details and callback function
  final Map<String, dynamic> user;
  final Function callback;

  // Creates the state for the SuggestionListWidget
  @override
  State<SuggestionListWidget> createState() => _SuggestionListWidget();
}

// _SuggestionListWidget class is the state of the SuggestionListWidget
class _SuggestionListWidget extends State<SuggestionListWidget> {
  // Handles the press event on the suggestion item
  void handlePress() async {
    String currentUser = widget.user["user_id"];
    sendUser(currentUser);
  }

  // Navigates to the PrivateMessage screen with the selected user
  void sendUser(String currentUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrivateMessage(
          index: 1,
          user: widget.user,
          callback: widget.callback,
          currentUser: currentUser,
        ),
      ),
    );
  }

  // Builds the suggestion item widget
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => handlePress(),
      child: Container(
        // Container styling
        decoration: BoxDecoration(
          color: const Color(0xbb000000),
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // User avatar section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: widget.user["avatar_id"] == null
                  ? Shimmer.fromColors(
                      // Shimmer effect for loading state
                      baseColor: shimmer["base"]!,
                      highlightColor: shimmer["highlight"]!,
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: swatch[900],
                      ),
                    )
                  : widget.user["avatar_id"] != "default"
                      ? CachedNetworkImage(
                          // Cached network image for user avatar
                          imageUrl:
                              '${Config.uri}/image/thumbnail/${widget.user["avatar_id"]}',
                          imageBuilder: (context, imageProvider) => Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : const DefaultProfile(radius: 26),
            ),
            // User username text
            Text(
              widget.user["username"] ?? AppLocalizations.of(context)!.username,
              style: TextStyle(color: swatch[701]),
            ),
            const Spacer(
              flex: 10,
            ),
            // Follow button section
            TextButton(
              onPressed: () => commonLogger.i("pressed"),
              child: const Icon(Icons.chevron_right),
            ),
            const Spacer()
          ],
        ),
      ),
    );
  }
}
