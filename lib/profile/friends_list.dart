import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:patinka/api/config/config.dart";
import "package:patinka/profile/connections_list.dart";
import "package:patinka/profile/list_type.dart";
import "package:patinka/swatch.dart";

// FollowingList widget

class FriendsList extends StatelessWidget {

  const FriendsList({super.key, this.user});
  final Map<String, dynamic>? user;

  @override
  Widget build(final BuildContext context) => Scaffold(
        backgroundColor: const Color(0x34000000),
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
            iconTheme: IconThemeData(color: swatch[701]),
            elevation: 8,
            shadowColor: Colors.green.shade900,
            backgroundColor: Config.appbarColour,
            foregroundColor: Colors.transparent,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            title: Text(
              "Friends",
              style: TextStyle(color: swatch[701]),
            )),
        body: ConnectionsListView(
          type: ListType.friendsList,
          user: user,
        ));
}
