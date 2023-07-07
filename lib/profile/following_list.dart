import 'package:flutter/material.dart';

import 'connections_list.dart';

// FollowingList widget

class FollowingList extends StatelessWidget {
  final Map<String, dynamic>? user;
  const FollowingList({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return ConnectionsListView(type: "following", user: user);
  }
}
