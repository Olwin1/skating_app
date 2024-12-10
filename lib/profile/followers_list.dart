import "package:flutter/material.dart";
import "package:patinka/profile/connections_list.dart";
import "package:patinka/profile/list_type.dart";

// FollowersList widget

class FollowersList extends StatelessWidget {

  const FollowersList({super.key, this.user});
  final Map<String, dynamic>? user;

  @override
  Widget build(final BuildContext context) => ConnectionsListView(
      type: ListType.followersList,
      user: user,
    );
}
