import 'package:flutter/material.dart';
import 'package:skating_app/objects/user.dart';

class FriendsTracker extends StatelessWidget {
  // Constructor that takes a key and a title as required arguments
  const FriendsTracker({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    // create an instance of the User class and passing it an id of '1'
    User user = User("1");
    return Scaffold(
        // Scaffold widget, which is the basic layout element in Flutter
        body: Container());
  }
}
