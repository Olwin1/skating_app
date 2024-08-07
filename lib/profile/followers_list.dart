import 'package:flutter/material.dart';
import 'package:patinka/profile/connections_list.dart';
import 'package:patinka/profile/list_type.dart';

// FollowersList widget

class FollowersList extends StatelessWidget {
  final Map<String, dynamic>? user;

  const FollowersList({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return ConnectionsListView(
      type: ListType.followersList,
      user: user,
    );
  }
}
