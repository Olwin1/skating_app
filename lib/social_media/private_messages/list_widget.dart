import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
// Importing external configurations and utility widgets
import "package:patinka/api/config.dart";
import "package:patinka/api/messages.dart";
import "package:patinka/misc/default_profile.dart";
import "package:patinka/social_media/private_messages/private_message.dart";
import "package:patinka/swatch.dart";
import "package:shimmer/shimmer.dart";

// StatefulWidget to represent a list item in the UI
class ListWidget extends StatefulWidget {
  // Constructor to initialize the widget with required properties
  const ListWidget({
    required this.index, required this.channel, required this.desc, required this.currentUser, required this.refreshPage, super.key,
  });

  // Properties of the ListWidget
  final int index;
  final Map<String, dynamic> channel;
  final String desc;
  final String currentUser;
  final VoidCallback refreshPage;

  @override
  State<ListWidget> createState() => _ListWidget(); // Create state for widget
}

// State class for ListWidget
class _ListWidget extends State<ListWidget> {
  @override
  Widget build(final BuildContext context) {
    // Variable to store information about the user associated with the channel
    Map<String, dynamic>? user;

    // Iterate through participants to find the user associated with the channel
    for (final participant in widget.channel["participants"]) {
      if (participant["users"]["user_id"] != widget.currentUser) {
        user = participant["users"];
        break;
      }
    }

    // Function to navigate back in the widget tree
    void popNavigator() {
      Navigator.of(context).pop();
    }

    // UI structure for each list item
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xb5000000),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        height: 84,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextButton(
          onLongPress: () async {
            // Show a confirmation dialog for channel deletion
            await showDialog(
              useRootNavigator: false,
              context: context,
              builder: (final BuildContext context) => AlertDialog(
                  backgroundColor: swatch[800],
                  title: Text(
                    "Are you sure you want to delete this channel?",
                    style: TextStyle(color: swatch[701]),
                  ),
                  content: SizedBox(
                    height: 96,
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () async {
                            // Delete the channel, refresh the page, and close the dialog
                            await MessagesAPI.delChannel(
                                widget.channel["channel_id"]);
                            widget.refreshPage();
                            popNavigator();
                          },
                          child: Text(
                            "Delete",
                            style: TextStyle(color: swatch[901]),
                          ),
                        ),
                        TextButton(
                          onPressed: popNavigator,
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: swatch[901]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            );
          },
          onPressed: () {
            // Navigate to PrivateMessage page when the list item is clicked
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (final context) => PrivateMessage(
                  initSelf: false,
                  channel: widget.channel,
                  user: user,
                  currentUser: widget.currentUser,
                ),
              ),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display user avatar or default avatar if not available
              user == null
                  ? Shimmer.fromColors(
                      baseColor: shimmer["base"]!,
                      highlightColor: shimmer["highlight"]!,
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: swatch[900],
                      ),
                    )
                  : Flexible(
                      child: (user["avatar_id"] != null &&
                              user["avatar_id"] != "default")
                          ? CachedNetworkImage(
                              imageUrl:
                                  '${Config.uri}/image/${user["avatar_id"]}',
                              httpHeaders: const {"thumbnail": "true"},
                              placeholder: (final context, final url) => Shimmer.fromColors(
                                baseColor: shimmer["base"]!,
                                highlightColor: shimmer["highlight"]!,
                                child: CircleAvatar(
                                  radius: 26,
                                  backgroundColor: swatch[900],
                                ),
                              ),
                              imageBuilder: (final context, final imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            )
                          : const DefaultProfile(radius: 26),
                    ),
              const Padding(padding: EdgeInsets.only(left: 16)),
              Flexible(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(padding: EdgeInsets.only(top: 10)),
                    // Display user's name or default text for channels
                    Text(
                      user?["username"] ?? "Channel",
                      style: TextStyle(color: swatch[301]),
                    ),
                    // Display channel description or last message sent
                    Text(
                      widget.desc,
                      style: TextStyle(color: swatch[601], height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
