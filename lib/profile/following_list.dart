import 'package:flutter/material.dart';
import 'package:skating_app/profile/user_list_widget.dart';

// FollowingList widget
class FollowingList extends StatefulWidget {
  const FollowingList({Key? key}) : super(key: key);

  @override
  State<FollowingList> createState() => _FollowingList();
}

class _FollowingList extends State<FollowingList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      // Returns a ListView widget
      padding: const EdgeInsets.all(8),
      children: const [
        // A list of UserListWidget widgets
        UserListWidget(title: "title"),
        UserListWidget(title: "title"),
        UserListWidget(title: "title"),
        UserListWidget(title: "title"),
        UserListWidget(title: "title"),
        UserListWidget(title: "title"),
        UserListWidget(title: "title"),
        UserListWidget(title: "title"),
        UserListWidget(title: "title"),
      ],
    );
  }
}
