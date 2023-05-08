import 'package:flutter/material.dart';
import 'package:skating_app/profile/connections_list.dart';

// FollowersList widget

class FollowersList extends StatelessWidget {
  const FollowersList({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConnectionsListView(type: "followers");
  }
}
