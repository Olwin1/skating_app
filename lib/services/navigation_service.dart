import 'package:flutter/material.dart';
import 'package:patinka/common_logger.dart';

class NavigationService extends ChangeNotifier {
  static final Map<String, GlobalKey<NavigatorState>> navigatorKeys = {
    "0": GlobalKey<
        NavigatorState>(), // Create an individual navigation stack for each item
    "1": GlobalKey<NavigatorState>(),
    "2": GlobalKey<NavigatorState>(),
    "3": GlobalKey<NavigatorState>(),
    "4": GlobalKey<NavigatorState>(),
  };

  static int _currentIndex = 0;

  // Set the current index
  static void setCurrentIndex(int index) {
    if (index >= 0 && index < navigatorKeys.length) {
      _currentIndex = index;
      commonLogger.d("Setting current navigator to $index");
      // Notify listeners about the change
      instance.notifyListeners();
    } else {
      throw RangeError("Index out of range");
    }
  }

  // Get the current index
  static int getCurrentIndex() {
    commonLogger.d("Get current index");
    return _currentIndex;
  }

  // Get the currently selected NavigatorState
  static GlobalKey<NavigatorState> get currentNavigatorKey {
    commonLogger.d("Getting Current Navigator of $_currentIndex");
    return navigatorKeys[_currentIndex.toString()]!;
  }

  static GlobalKey<NavigatorState>? navigatorKey(String index) {
    commonLogger.d("Getting Navigator of $index");
    return navigatorKeys[index];
  }

  // Singleton instance to allow non-static access to ChangeNotifier methods
  static final NavigationService instance = NavigationService();

  @override
  void dispose() {
    instance.dispose();
    super.dispose();
  }

  // ... other methods and getters
}
