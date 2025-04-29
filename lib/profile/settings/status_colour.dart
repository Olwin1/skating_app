import "package:flutter/material.dart";

class StatusColour {
  static Color getColour(final String status) {
    Color statusColour;
    switch (status) {
      case "pending_review":
        statusColour = Colors.green;
      case "invalid":
        statusColour = Colors.red;
      case "valid_no_action":
        statusColour = Colors.amber.shade900;
      case "warning_issued":
        statusColour = Colors.amber.shade700;
      case "temporary_ban":
        statusColour = Colors.red.shade600;
      case "permanent_ban":
        statusColour = Colors.red.shade900;
      case "further_investigation":
        statusColour = Colors.purple.shade400;
      case "escalated":
        statusColour = Colors.pink.shade900;
      case "resolved":
        statusColour = Colors.grey.shade500;
      case "closed_no_resolution":
        statusColour = Colors.black;
      default:
        statusColour = Colors.indigo;
    }
    return statusColour;
  }

  static List<String> getStatusList() => [
      "pending_review",
      "invalid",
      "valid_no_action",
      "warning_issued",
      "temporary_ban",
      "permanent_ban",
      "further_investigation",
      "escalated",
      "resolved",
      "closed_no_resolution"
    ];
}
