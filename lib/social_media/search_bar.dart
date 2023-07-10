import 'package:flutter/material.dart';
import 'package:patinka/social_media/search_results.dart';
import '../swatch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchBarr extends StatefulWidget {
  // Create HomePage Class
  const SearchBarr({Key? key})
      : super(key: key); // Take 2 arguments optional key and title of post
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
          isDense: true,
          isCollapsed: true,
          filled: true,
          fillColor: swatch[601]!,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: const BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        onSubmitted: (value) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchResults(query: controller.text)));
        },
      ),
    ));
  }
}
