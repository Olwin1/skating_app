import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/api/social.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/profile/profile_page/profile_page.dart';
import '../api/config.dart';
import '../misc/default_profile.dart';
import '../swatch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Flag to track if the user is entering a search query
bool entering = false;

class SearchResults extends StatefulWidget {
  final String query;

  // Constructor for the SearchResults widget
  const SearchResults({super.key, required this.query});

  @override
  State<SearchResults> createState() => _SearchResults();
}

class _SearchResults extends State<SearchResults> {
  // Initialize a TextEditingController to control the input text field
  TextEditingController controller = TextEditingController();
  String? currentQuery;

  @override
  void initState() {
    // Initialize the currentQuery variable with the initial query value
    currentQuery = widget.query;
    controller.text =
        currentQuery!; // Set the text field value to the current query
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x84000000),
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        // Styling for the app bar
        iconTheme: IconThemeData(color: swatch[701]),
        elevation: 0,
        shadowColor: Colors.green.shade900,
        backgroundColor: Config.appbarColour,
        foregroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Container(
          padding: const EdgeInsets.all(8),
          child: TextField(
            // Search input field
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
              // Styling for the input field border
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide(
                  color: Colors.green.shade900,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide(
                  color: Colors.green.shade900,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            ),
            style: TextStyle(color: swatch[901]),
            onSubmitted: (value) {
              entering = false; // Set entering flag to false
              mounted
                  ? setState(() {
                      currentQuery = controller.text;
                    })
                  : null;
            },
          ),
        ),
      ),
      body: Container(
        child: currentQuery == null
            ? const SizedBox.shrink()
            : SearchResultsList(query: currentQuery!),
      ),
    );
  }
}

class SearchResultsList extends StatefulWidget {
  final String query;

  const SearchResultsList({super.key, required this.query});

  @override
  State<SearchResultsList> createState() => _SearchResultsList();
}

List<Map<String, dynamic>> results = [];

class _SearchResultsList extends State<SearchResultsList> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Check if entering is true, and if so, return the Results widget with the current results
    if (entering) {
      return Results(results: results);
    }

    // Set entering to true
    entering = true;

    // Print the search query
    commonLogger.t("searching users ${widget.query}");

    // Call the searchUsers function with the query and handle the returned value
    SocialAPI.searchUsers(widget.query).then((value) => mounted
        ? setState(
            () {
              commonLogger.d("eeeeeeeeeeeeeeeeeeeee $value");
              results = value;
            },
          )
        : null);

    // Return the Results widget with the updated results
    return Results(results: results);
  }
}

class Results extends StatelessWidget {
  const Results({super.key, required this.results});
  final List<Map<String, dynamic>> results;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xb5000000),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          height: 84,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  userId: results[index]["user_id"],
                  navbar: false,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Display user avatar or default profile if not available
                results[index]["avatar_id"] == null
                    ? const DefaultProfile(radius: 24)
                    : Flexible(
                        child: CachedNetworkImage(
                          imageUrl:
                              '${Config.uri}/image/thumbnail/${results[index]["avatar_id"]}',
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: shimmer["base"]!,
                            highlightColor: shimmer["highlight"]!,
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: swatch[900],
                            ),
                          ),
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                const Padding(padding: EdgeInsets.only(left: 16)),
                Flexible(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                      ),
                      // Display username
                      Text(
                        results[index]["username"] ?? "Channel",
                        style: TextStyle(
                          color: swatch[301],
                        ),
                      ),
                      // Display user description with text overflow handling
                      Text(
                        results[index]["description"] ?? "",
                        style: TextStyle(color: swatch[601], height: 1.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
