import 'package:flutter/material.dart';
import './/objects/post.dart';

class User {
  String? userId;

  // Read-only non-final property
  String email = "testing@example.com";
  String username = "test343";
  String displayName = "test3";
  Image profileImage =
      const Image(image: AssetImage("assets/placeholders/150.png"));
  var posts = [Post("1"), Post("2"), Post("3")];

  // Constructor.
  User(this.userId) {
    // Initialization code goes here.
  }

  // Named constructor that forwards to the default one.
  User.create(String userId) : this(null);

  // Method.
  String? getId() {
    print('User Id: $userId');
    // Type promotion doesn't work on getters.
    if (userId != null) {
      return userId;
    } else {
      print('Invalid User');
      return null;
    }
  }
}
