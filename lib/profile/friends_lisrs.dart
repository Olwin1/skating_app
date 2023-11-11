import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/config.dart';
import '../swatch.dart';
import 'connections_list.dart';

// FollowingList widget

class FriendsList extends StatelessWidget {
  final Map<String, dynamic>? user;

  const FriendsList({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
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
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: const AssetImage("assets/backgrounds/graffiti.png"),
                  fit: BoxFit.cover,
                  alignment: Alignment.topRight,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5), BlendMode.srcOver)),
            ),
            child: ConnectionsListView(
              type: "friends",
              user: user,
            )));
  }
}
