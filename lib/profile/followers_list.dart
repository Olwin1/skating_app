import 'package:flutter/material.dart';
import 'package:skating_app/profile/connections_list.dart';

// FollowersList widget

class FollowersList extends StatelessWidget {
  final Map<String, dynamic>? user;

  const FollowersList({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return ConnectionsListView(
      type: "followers",
      user: user,
    );
  }
}
