import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:patinka/profile/profile_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/objects/user.dart';

import '../api/config.dart';
import '../swatch.dart';

// UserListWidget class creates a stateful widget that displays a list of users
class UserListWidget extends StatefulWidget {
  // Constructor for UserListWidget
  const UserListWidget({Key? key, required this.id}) : super(key: key);

  // Title for the widget
  final String id;

  // Creates the state for the UserListWidget
  @override
  State<UserListWidget> createState() => _UserListWidget();
}

// _UserListWidget class is the state of the UserListWidget
class _UserListWidget extends State<UserListWidget> {
  Map<String, dynamic>? user;
  handlePress() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Profile(
                  userId: user?["_id"],
                )));
  }

  // Builds the widget
  @override
  Widget build(BuildContext context) {
    if (user == null) {
      getUserCache(widget.id).then((value) => mounted
          ? setState(() {
              user = value;
            })
          : null);
    }
    // Returns a row with a CircleAvatar, a text widget, and a TextButton
    return GestureDetector(
        onTap: () => handlePress(),
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
                  child: user?["avatar"] == null
                      ? Shimmer.fromColors(
                          baseColor: const Color(0x66000000),
                          highlightColor: const Color(0xff444444),
                          child: CircleAvatar(
                            // Create a circular avatar icon
                            radius: 26, // Set radius to 36
                            backgroundColor: swatch[900]!,
                          ))
                      : CachedNetworkImage(
                          imageUrl:
                              '${Config.uri}/image/thumbnail/${user!["avatar"]}',
                          imageBuilder: (context, imageProvider) => Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape
                                  .circle, // Set the shape of the container to a circle
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                ),
                // Text widget with the text "username"
                Text(
                  user?["username"] ?? AppLocalizations.of(context)!.username,
                  style: TextStyle(color: swatch[701]),
                ),
                const Spacer(
                  flex: 10,
                ),
                // TextButton with an onPressed function that prints test value "ee" and a child text widget with the text "Follow"
                TextButton(
                    onPressed: () => commonLogger.i("pressed"),
                    child: Text(AppLocalizations.of(context)!.follow)),
                const Spacer()
              ],
            )));
  }
}
