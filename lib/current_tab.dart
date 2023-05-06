import 'package:flutter/foundation.dart';

// Define a class named CurrentPage that extends ChangeNotifier.
class CurrentPage extends ChangeNotifier {
  // Define a private integer variable named _tab and initialize it to 0.
  int _tab = 0;

  // Define a getter method named 'tab' that returns the value of the _tab variable.
  int get tab => _tab;

  // Define a setter method named 'set' that takes a parameter named 'tab'.
  void set(tab) {
    // Set the value of the _tab variable to the value of the 'tab' parameter.
    _tab = tab;
    // Notify any listeners that the value of the _tab variable has changed.
    notifyListeners();
  }

  // Define a method named 'reset' that sets the value of the _tab variable to 0.
  void reset() {
    _tab = 0;
    // Notify any listeners that the value of the _tab variable has changed.
    notifyListeners();
  }
}
