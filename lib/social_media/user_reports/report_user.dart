import 'package:flutter/material.dart';
import 'package:patinka/services/navigation_service.dart';
import 'package:provider/provider.dart';

import '../../misc/navbar_provider.dart';

// Enum to define different animation styles for the modal bottom sheet
enum AnimationStyle { defaultStyle, custom, none }

class ModalBottomSheet {
  // Static method to show the modal bottom sheet
  static void show(
      {required BuildContext context, // The BuildContext for navigation
      required Widget Function(BuildContext)
          builder, // The builder to create the content of the modal
      AnimationStyle animationStyle = AnimationStyle
          .defaultStyle, // The animation style for the modal (default: defaultStyle)
      double startSize = 0.4, bool hideNavbar = true}) {
    // The initial size of the modal (default: 40% of the screen height)

    // Hide the bottom navbar before showing the modal
    hideNavbar?Provider.of<BottomBarVisibilityProvider>(context, listen: false).hide():null;

    // Show the modal bottom sheet with customized options
    showModalBottomSheet<void>(
        backgroundColor:
            Colors.grey.shade900, // Dark background color for the modal
        context: context, // The BuildContext for the modal
        isScrollControlled:
            true, // Allows the modal to be scrollable and adjust its height
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.0), // Rounded top corners for the modal
          ),
        ),
        builder: (BuildContext context) {
          // DraggableScrollableSheet allows the user to drag and resize the modal
          return DraggableScrollableSheet(
              initialChildSize:
                  startSize, // Initial size of the modal as a percentage of screen height
              minChildSize:
                  0.2, // Minimum height of the modal (20% of screen height)
              maxChildSize:
                  0.9, // Maximum height of the modal (90% of screen height)
              expand: false, // Prevents the modal from expanding to full screen
              snap: false, // Disables snapping behavior when dragging the modal
              builder:
                  (BuildContext context, ScrollController scrollController) {
                // Wrap the modal content in a SingleChildScrollView to allow scrolling
                return SingleChildScrollView(
                    controller:
                        scrollController, // Attach the scrollController for scrolling functionality
                    child: Column(
                      children: [
                        // Handle the handle bar at the top of the modal
                        Container(
                          margin: const EdgeInsets.only(
                              top:
                                  8.0), // Margin to space the handle bar from the top
                          width: 60.0, // Width of the handle bar
                          height: 3.5, // Height of the handle bar
                          decoration: BoxDecoration(
                            color: Colors.grey
                                .shade400, // Light grey color for the handle
                            borderRadius: BorderRadius.circular(
                                24.0), // Rounded corners for the handle
                          ),
                        ),
                        // Padding to create space before the modal content starts
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: builder(
                                context)), // Call the builder to display the modal content
                      ],
                    ));
              });
        }).whenComplete(() {
      // Once the modal is dismissed, show the bottom navbar again
      if (hideNavbar&&NavigationService.currentNavigatorKey.currentState != null &&
          NavigationService.currentNavigatorKey.currentState!.mounted !=
              false) {
        // Ensure the current context is still mounted and then show the navbar
        Provider.of<BottomBarVisibilityProvider>(
                NavigationService.currentNavigatorKey.currentState!.context,
                listen: false)
            .show();
      }
    });
  }
}
