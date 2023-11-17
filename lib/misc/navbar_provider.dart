import 'package:flutter/material.dart';

class BottomBarVisibilityProvider extends ChangeNotifier {
  bool isVisible = true;

  void show() {
    if (!isVisible) {
      isVisible = true;
      // Using Future to schedule the notification after the build phase
      Future.microtask(() {
        notifyListeners();
      });
    }
  }

  void hide() {
    if (isVisible) {
      isVisible = false;
      // Using Future to schedule the notification after the build phase
      Future.microtask(() {
        notifyListeners();
      });
    }
  }
}
