import 'dart:ui';

import 'package:patinka/api/social.dart';
// Export login and signup functions from auth.dart
export 'package:patinka/social_media/handle_buttons.dart';


  // Colors for UI elements
  Color selected = const Color.fromARGB(255, 136, 255, 0);
  Color unselected = const Color.fromARGB(255, 31, 207, 46);
  Color secondary = const Color.fromARGB(255, 15, 95, 5);

  bool waiting = false; // Flag for ongoing operations
  bool waitingSave = false; // Flag for ongoing operations

  // Handle the like button press
  Future<bool> handleLikePressed(
      bool isLiked, Function setLikedState, Map<String, dynamic>? post) async {
                if(post == null) {
          return isLiked;
        }
    if (!waiting) {
      if (isLiked) {
        // Unlike the post
        try {
          waiting = true;
          await SocialAPI.unlikePost(post["post_id"]);
          setLikedState(false);
          waiting = false;
          return !isLiked;
        } catch (e) {
          waiting = true;
          return isLiked;
        }
      } else {
        // Like the post
        try {
          waiting = true;
          await SocialAPI.likePost(post["post_id"]);
          setLikedState(true);
          waiting = false;
          return !isLiked;
        } catch (e) {
          waiting = false;
          return isLiked;
        }
      }
    }
    return isLiked;
  }

  // Handle the like button press
  Future<bool> handleSavePressed(
      bool isSaved, Function setSavedState, Map<String, dynamic>? post) async {
        if(post == null) {
          return isSaved;
        }
    if (!waitingSave) {
      if (isSaved) {
        // Unlike the post
        try {
          waitingSave = true;
          await SocialAPI.unsavePost(post["post_id"]);
          setSavedState(false);
          waitingSave = false;
          return !isSaved;
        } catch (e) {
          waitingSave = false;
          return isSaved;
        }
      } else {
        // Like the post
        try {
          waitingSave = true;
          await SocialAPI.savePost(post["post_id"]);
          setSavedState(true);
          waitingSave = false;
          return !isSaved;
        } catch (e) {
          waitingSave = false;
          return isSaved;
        }
      }
    }
    return isSaved;
  }

