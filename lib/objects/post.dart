import 'package:flutter/material.dart';

class Post {
  String? postId;

  // Read-only non-final property
  String title = "postTitle";
  String description = "postDesc";
  int likes = 32;

  Image postImage =
      const Image(image: AssetImage("assets/placeholders/1080.png"));

  // Constructor.
  Post(this.postId) {
    // Initialization code goes here.
  }

  // Named constructor that forwards to the default one.
  Post.create(String userId) : this(null);

  // Method.
  String? getId() {
    print('Post Id: $postId');
    // Type promotion doesn't work on getters.
    if (postId != null) {
      return postId;
    } else {
      print('Invalid Post');
      return null;
    }
  }
}
