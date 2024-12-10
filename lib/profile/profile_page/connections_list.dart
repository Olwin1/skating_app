import "package:flutter/material.dart";
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import "package:patinka/api/messages.dart";
import "package:patinka/profile/friends_list.dart";
import "package:patinka/profile/lists.dart";
import "package:patinka/swatch.dart";

class ConnectionLists extends StatelessWidget {

  const ConnectionLists({super.key, this.user});
  final Map<String, dynamic>? user;
  @override
  Widget build(final BuildContext context) {
    String? self = "";
    if (user != null) {
      MessagesAPI.getUserId().then((final value) => self = value);
    }
    return Expanded(
        child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: const Color.fromARGB(125, 0, 0, 0),
                borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Spacer(),
              GestureDetector(
                  onTap: () => Navigator.push(
                      // Send to edit profile page
                      context,
                      MaterialPageRoute(
                          builder: (final context) => FriendsList(
                                user: user?["user_id"] != self ? user : null,
                              ))),
                  child: Column(children: [
                    Text((user?["friends"] ?? 0).toString(),
                        style: TextStyle(color: swatch[601])),
                    Text(AppLocalizations.of(context)!.friends,
                        style: TextStyle(color: swatch[701]))
                  ])),
              // Column to display the number of followers
              const Spacer(),

              GestureDetector(
                  onTap: () => Navigator.push(
                      // Send to edit profile page
                      context,
                      MaterialPageRoute(
                          builder: (final context) => Lists(
                                index: 0,
                                user: user?["user_id"] != self ? user : null,
                              ))),
                  child: Column(children: [
                    Text((user?["followers"] ?? 0).toString(),
                        style: TextStyle(color: swatch[601])),
                    Text(AppLocalizations.of(context)!.followers,
                        style: TextStyle(color: swatch[701]))
                  ])),
              // Column to display the number of following
              const Spacer(),

              GestureDetector(
                  onTap: () => Navigator.push(
                      // Send to edit profile page
                      context,
                      MaterialPageRoute(
                          builder: (final context) => Lists(
                                index: 1,
                                user: user?["user_id"] != self ? user : null,
                              ))),
                  child: Column(children: [
                    Text((user?["following"] ?? 0).toString(),
                        style: TextStyle(color: swatch[601])),
                    Text(AppLocalizations.of(context)!.following,
                        style: TextStyle(color: swatch[701]))
                  ])),
              const Spacer(),
            ])));
  }
}
