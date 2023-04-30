import 'package:flutter/material.dart';
import 'package:skating_app/profile/user_list_widget.dart';

// FollowersList widget
class FollowersList extends StatefulWidget {
  const FollowersList({Key? key}) : super(key: key);

  @override
  State<FollowersList> createState() => _FollowersList();
}

class _FollowersList extends State<FollowersList> {
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
