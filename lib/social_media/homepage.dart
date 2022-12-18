import 'package:flutter/material.dart';
import 'package:skating_app/objects/user.dart';

class HomePage extends StatelessWidget {
  // Create HomePage Class
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title; // Define title argument

  @override // Override the existing widget build method
  Widget build(BuildContext context) {
    User user = User("1"); // Create user object with id of 1
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: user.posts[0].postImage, // Add Placeholder text
      ),
    );
  }
}
