import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:patinka/api/config/config.dart";
import "package:patinka/api/support.dart";
import "package:patinka/misc/default_profile.dart";
import "package:patinka/swatch.dart";
import "package:shimmer/shimmer.dart";


// BlockedUserListWidget class creates a stateful widget that displays a list of users
class BlockedUserListWidget extends StatefulWidget {
  // Constructor for BlockedUserListWidget
  const BlockedUserListWidget(
      {required this.user,
      required this.refreshPage,
      super.key
      });

  // Title for the widget
  final Map<String, dynamic> user;
  final VoidCallback refreshPage;
  // Creates the state for the BlockedUserListWidget
  @override
  State<BlockedUserListWidget> createState() => _BlockedUserListWidget();
}

// _BlockedUserListWidget class is the state of the BlockedUserListWidget
class _BlockedUserListWidget extends State<BlockedUserListWidget> {

  void handleDelete() async {
    await SupportAPI.postUnblockUser(widget.user["user_id"]);
    widget.refreshPage();
  }

  // Builds the widget
  @override
  Widget build(final BuildContext context) => GestureDetector(
      child: Container(
          decoration: BoxDecoration(
            color: const Color(0xbb000000),
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // CircleAvatar with a radius of 26 and a background image from the assets folder
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                child: widget.user["avatar_id"] != null
                    ? CachedNetworkImage(
                        placeholder: (final context, final url) =>
                            Shimmer.fromColors(
                                baseColor: shimmer["base"]!,
                                highlightColor: shimmer["highlight"]!,
                                child: Image.asset(
                                    "assets/placeholders/1080.png")),
                        imageUrl:
                            '${Config.uri}/image/thumbnail/${widget.user["avatar_id"]}',
                        imageBuilder: (final context, final imageProvider) =>
                            Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape
                                .circle, // Set the shape of the container to a circle
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                      )
                    : const DefaultProfile(radius: 26),
              ),
              // Text widget with the text "username"
              Text(
                widget.user["username"] ??
                    AppLocalizations.of(context)!.username,
                style: TextStyle(color: swatch[701]),
              ),
              const Spacer(
                flex: 10,
              ),
              // TextButton with an onPressed function that prints test value "ee" and a child text widget with the text "Follow"
              TextButton(
                      onPressed: handleDelete,
                      child: Text("Unblock", style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 15),)
                      ),
              const Spacer()
            ],
          )));
}
