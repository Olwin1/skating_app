// Import necessary packages and files
import 'package:flutter/material.dart';
import 'package:patinka/social_media/search_results.dart';
import '../swatch.dart'; // File containing color definitions
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Define a StatefulWidget class for the search bar
class SearchBarr extends StatefulWidget {
  // Constructor for SearchBarr widget
  const SearchBarr({super.key});

  // Create state for the widget
  @override
  State<SearchBarr> createState() => _SearchBarState();
}

// Define the state class for the SearchBarr widget
class _SearchBarState extends State<SearchBarr> {
  TextEditingController controller = TextEditingController();

  // Override the build method to define the widget's UI
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: TextField(
          controller: controller,
          showCursor: true,
          maxLines: 1,
          textAlignVertical: TextAlignVertical.center,
          cursorColor: swatch[801],

          // Define the appearance of the input field
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide(
                color: Colors.green.shade900,
                width: 2,
              ),
            ),
            hintText: AppLocalizations.of(context)!.search,
            hintStyle: const TextStyle(color: Color(0x77ffffff)),
            isDense: true,
            isCollapsed: true,
            filled: true,
            fillColor: const Color(0x66000000),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide(
                color: Colors.green.shade900,
                width: 1,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide(
                color: Colors.green.shade900,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 16,
            ),
          ),

          // Define the text style for the input
          style: TextStyle(color: swatch[901]),

          // Callback function when the user submits the search query
          onSubmitted: (value) {
            // Navigate to the search results page
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    SearchResults(query: controller.text),
                opaque: false,
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = 0.0;
                  const end = 1.0;
                  var tween = Tween(begin: begin, end: end);
                  var fadeAnimation = tween.animate(animation);
                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: child,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
