import 'package:flutter/material.dart';
import 'package:patinka/services/role.dart';
import 'package:patinka/swatch.dart';

class StatusDropdown extends StatefulWidget {
  final Map<String, dynamic> report;
  final Function(Status) onStatusChanged; // Callback to handle status change

  const StatusDropdown(
      {super.key, required this.report, required this.onStatusChanged});

  @override
  State<StatusDropdown> createState() => _StatusDropdown();
}

class _StatusDropdown extends State<StatusDropdown> {
  // The selected status
  late Status selectedStatus;

  @override
  void initState() {
    super.initState();
    // Initialize the selected status to the report's status
    selectedStatus = RoleServices.convertToStatus(widget.report["status"]);
  }

  @override
  Widget build(BuildContext context) {
    Color statusColour = _getStatusColour(
        selectedStatus); // Function to get color based on status

    return Container(
      height: 52,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: statusColour,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Status>(
          selectedItemBuilder: (BuildContext context) {
            return Status.values.map<Widget>((Status status) {
              return Center(
                  child: Text(
                status.name,
                // Text style for the selected item (when dropdown is unfocused)
                style: const TextStyle(
                    color:
                        Colors.white), // Set desired color for unfocused item
              ));
            }).toList();
          },
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(8),
          value: selectedStatus,
          items: Status.values.map((Status status) {
            return DropdownMenuItem<Status>(
              value: status,
              child: Text(
                status.name,
                style: TextStyle(color: _getStatusColour(status)),
              ),
            );
          }).toList(),
          onChanged: (Status? newValue) {
            setState(() {
              selectedStatus = newValue!;
              widget.onStatusChanged(
                  newValue); // Notify the parent widget about status change
            });
          },
          // Customize dropdown appearance
          dropdownColor:
              const Color(0xcc000000), // Dropdown will have the same color
          style: TextStyle(
              color: _getStatusColour(selectedStatus)), // Customize text color
        ),
      ),
    );
  }

  // Helper function to get status color based on the status
  Color _getStatusColour(Status status) {
    Color statusColour = status == Status.closed
        ? Colors.red.shade700
        : status == Status.open
            ? swatch[100]!
            : swatch[500]!;
    return statusColour;
  }
}
