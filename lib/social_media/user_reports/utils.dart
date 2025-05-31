import "package:flutter/material.dart";

class ButtonBuilders {
  // Creates a custom TextButton with an icon and text
  static Widget createTextButton(final IconData icon, final String text,
          final Color color, final Function callback) =>
      TextButton(
        // onPressed callback that triggers the passed function when the button is pressed
        onPressed: callback as VoidCallback,
        // Child widget inside the TextButton
        child: Container(
          // Padding applied to the button content (vertical padding)
          padding: const EdgeInsets.symmetric(vertical: 12),
          // Set the width of the container to be the maximum width of the parent
          width: double.maxFinite,
          // Row layout to place the icon and text horizontally
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon widget, colored based on the passed 'color' parameter
              Icon(
                icon,
                color: color,
              ),
              // Add some horizontal space between the icon and the text
              const SizedBox(width: 6),
              // Text widget that displays the passed 'text' with specified styling
              Text(
                text,
                style: TextStyle(
                  color: color, // Text color is set to the same as the icon
                  fontSize: 18, // Font size is set to 18
                ),
              ),
            ],
          ),
        ),
      );

  // Creates a custom TextButton with just text
  static Widget createTextReportButton(
          final String text, final Function callback) =>
      TextButton(
        // onPressed callback that triggers the passed function when the button is pressed
        onPressed: callback as VoidCallback,
        // Child widget inside the TextButton
        child: Container(
          // Padding applied to the button content (vertical padding)
          padding: const EdgeInsets.symmetric(vertical: 12),
          // Set the width of the container to be the maximum width of the parent
          width: double.maxFinite,
          // Single Text widget displaying the passed text
          child: Text(
            text,
            // Style for the text, using grey color and a smaller font size
            style: TextStyle(
              color: Colors.grey.shade400, // Grey color for text
              fontSize: 18, // Font size set to 16
            ),
          ),
        ),
      );
}
