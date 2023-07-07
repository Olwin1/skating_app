import 'package:flutter/material.dart';

import 'connections_list.dart';

// FollowingList widget

class FriendsList extends StatelessWidget {
  final Map<String, dynamic>? user;

  const FriendsList({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Friends")),
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
