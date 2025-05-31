import "package:flutter/material.dart";

/// Represents the three possible states of the toggle button.
enum ToggleButtonState {
  primary, // Shows the primary button.
  secondary, // Shows the secondary button.
  hidden // Hides the button entirely.
}

/// Abstract base class for a tri-state toggle button widget.
///
/// The widget maintains a button that can be in one of three states:
/// - `primary`: displays a primary icon, label, and color.
/// - `secondary`: displays a secondary icon, label, and color.
/// - `hidden`: no button is shown.
///
/// To use this, extend the class and implement the required abstract members.
abstract class TriButtonStateToggle<T extends TriButtonStateToggle<T>>
    extends StatefulWidget {
  /// Creates a tri-state toggle button.
  ///
  /// The [userId] is used for user-specific logic.
  const TriButtonStateToggle({required this.userId, super.key});

  /// Identifier for the user, for use in state decisions.
  final String userId;

  @override
  TriButtonStateToggleState<T> createState();
}

/// State class for [TriButtonStateToggle].
///
/// This handles logic for switching between the primary, secondary,
/// and hidden states, and rendering the corresponding button.
abstract class TriButtonStateToggleState<T extends TriButtonStateToggle<T>>
    extends State<T> {
  /// Current state of the button.
  ToggleButtonState buttonState = ToggleButtonState.primary;

  @override
  void initState() {
    super.initState();
    initButtonState(); // Initialize the button state asynchronously.
  }

  /// Asynchronously determines and sets the initial button state.
  Future<void> initButtonState();

  /// Called when the primary button is pressed.
  Future<void> onPrimaryPressed();

  /// Called when the secondary button is pressed.
  Future<void> onSecondaryPressed();

  /// Icon for the primary button.
  IconData get primaryIcon;

  /// Icon for the secondary button.
  IconData get secondaryIcon;

  /// Label for the primary button.
  String get primaryLabel;

  /// Label for the secondary button.
  String get secondaryLabel;

  /// Color of the primary button content.
  Color get primaryColor;

  /// Color of the secondary button content.
  Color get secondaryColor;

  @override
  Widget build(final BuildContext context) {
    // Build the appropriate button based on the current state.
    switch (buttonState) {
      case ToggleButtonState.primary:
        return _buildButton(
          primaryIcon,
          primaryLabel,
          primaryColor,
          onPrimaryPressed,
        );
      case ToggleButtonState.secondary:
        return _buildButton(
          secondaryIcon,
          secondaryLabel,
          secondaryColor,
          onSecondaryPressed,
        );
      case ToggleButtonState.hidden:
        return const SizedBox.shrink(); // No button shown.
    }
  }

  /// Builds a TextButton with an icon and label.
  ///
  /// [icon] - The icon to display.
  /// [label] - The label text.
  /// [color] - The color of the icon and label.
  /// [onPressed] - The callback when the button is pressed.
  Widget _buildButton(
    final IconData icon,
    final String label,
    final Color color,
    final Future<void> Function() onPressed,
  ) =>
      TextButton.icon(
        icon: Icon(icon, color: color),
        label: Text(label, style: TextStyle(color: color, fontSize: 16)),
        onPressed: () async {
          Navigator.pop(context); // Close current modal/dialog if open.
          await onPressed(); // Call the appropriate handler.
        },
      );
}
