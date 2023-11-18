import 'package:flutter/material.dart';
import 'package:patinka/social_media/search_results.dart';
import '../swatch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchBarr extends StatefulWidget {
  // Create HomePage Class
  const SearchBarr(
      {super.key}); // Take 2 arguments optional key and title of post
  @override
  State<SearchBarr> createState() => _SearchBar(); //Create state for widget
}

class _SearchBar extends State<SearchBarr> {
  @override
  void initState() {
    super.initState();
  }

  TextEditingController controller = TextEditingController();

  @override // Override existing build method
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: controller,
        showCursor: false,
        maxLines: 1,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.search,
          hintStyle: const TextStyle(color: Color(0x77ffffff)),
          isDense: true,
          isCollapsed: true,
          filled: true,
          fillColor: const Color(0x66000000),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide(
              color: Colors.green.shade900, // Change the border color to green
              width: 1, // You can adjust the border width
              style: BorderStyle.solid,
              // Remove strokeAlign, as it's not a valid property for BorderSide
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide(
              color: Colors.green.shade900, // Change the border color to green
              width: 1, // You can adjust the border width
              style: BorderStyle.solid,
              // Remove strokeAlign, as it's not a valid property for BorderSide
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        style: TextStyle(color: swatch[901]),
        onSubmitted: (value) {
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
    ));
  }
}
