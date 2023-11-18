import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class BottomBarVisibilityProvider extends ChangeNotifier
    implements TickerProvider {
  bool isVisible = true;
  late AnimationController _animationController;

  AnimationController get animationController => _animationController;

  BottomBarVisibilityProvider() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }
  void show() {
    if (!isVisible) {
      isVisible = true;
      _animationController.reverse();
      // Using Future to schedule the notification after the build phase
      Future.microtask(() {
        notifyListeners();
      });
    }
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }

  void hide() {
    if (isVisible) {
      _animationController.forward().then((value) => isVisible = false);

      // Using Future to schedule the notification after the build phase
      Future.microtask(() {
        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
