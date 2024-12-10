import "package:flutter/material.dart";
import "package:patinka/profile/connections_list.dart";
import "package:patinka/profile/list_type.dart";

// FollowingList widget

class FollowingList extends StatelessWidget {
  const FollowingList({super.key, this.user});
  final Map<String, dynamic>? user;

  @override
  Widget build(final BuildContext context) => ConnectionsListView(type: ListType.followingList, user: user);
}
