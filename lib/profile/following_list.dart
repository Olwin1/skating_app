import 'package:flutter/material.dart';

import 'connections_list.dart';

// FollowingList widget

class FollowingList extends StatelessWidget {
  const FollowingList({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConnectionsListView(type: "following");
  }
}
