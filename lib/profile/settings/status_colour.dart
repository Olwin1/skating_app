import 'package:flutter/material.dart';

class StatusColour {
  static Color getColour(String status) {
    Color statusColour;
    switch (status) {
      case "pending_review":
        statusColour = Colors.green;
        break;
      case "invalid":
        statusColour = Colors.red;
        break;
      case "valid_no_action":
        statusColour = Colors.amber.shade900;
        break;
      case "warning_issued":
        statusColour = Colors.amber.shade700;
        break;
      case "temporary_ban":
        statusColour = Colors.red.shade600;
        break;
      case "permanent_ban":
        statusColour = Colors.red.shade900;
        break;
      case "further_investigation":
        statusColour = Colors.purple.shade400;
        break;
      case "escalated":
        statusColour = Colors.pink.shade900;
        break;
      case "resolved":
        statusColour = Colors.grey.shade500;
        break;
      case "closed_no_resolution":
        statusColour = Colors.black;
        break;
      default:
        statusColour = Colors.indigo;
        break;
    }
    return statusColour;
  }

  static List<String> getStatusList() {
    return [
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
}
