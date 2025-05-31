import "package:flutter/material.dart";
import "package:patinka/api/social.dart";
import "package:patinka/api/support.dart";
import "package:patinka/social_media/user_reports/buttons/tri_button_state_toggle.dart";

class BlockButton extends TriButtonStateToggle<BlockButton> {
  const BlockButton({required super.userId, super.key});

  @override
  TriButtonStateToggleState<BlockButton> createState() => _BlockButtonState();
}

class _BlockButtonState extends TriButtonStateToggleState<BlockButton> {
  @override
  Future<void> initButtonState() async {
    final result = await SocialAPI.getUser(widget.userId);
    if (result.containsKey("blocked")) {
      setState(() {
        buttonState = result["blocked"]
            ? ToggleButtonState.secondary
            : ToggleButtonState.primary;
      });
    } else {
      setState(() => buttonState = ToggleButtonState.hidden);
    }
  }

  @override
  Future<void> onPrimaryPressed() async {
    await SupportAPI.postBlockUser(widget.userId);
  }

  @override
  Future<void> onSecondaryPressed() async {
    await SupportAPI.postUnblockUser(widget.userId);
  }

  @override
  IconData get primaryIcon => Icons.block;
  @override
  IconData get secondaryIcon => Icons.block;

  @override
  String get primaryLabel => "Block User";
  @override
  String get secondaryLabel => "Unblock User";

  @override
  Color get primaryColor => Colors.red.shade700;
  @override
  Color get secondaryColor => Colors.grey.shade400;
}
