import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:patinka/api/social.dart';
import 'package:patinka/common_logger.dart';
import 'package:patinka/profile/profile_page.dart';
import '../api/config.dart';
import '../misc/default_profile.dart';
import '../swatch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

bool entering = false;

class SearchResults extends StatefulWidget {
  final String query;

  const SearchResults({Key? key, required this.query}) : super(key: key);
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
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: swatch[701]),
        elevation: 8,
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
                  color:
                      Colors.green.shade900, // Change the border color to green
                  width: 1, // You can adjust the border width
                  style: BorderStyle.solid,
                  // Remove strokeAlign, as it's not a valid property for BorderSide
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide(
                  color:
                      Colors.green.shade900, // Change the border color to green
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
              entering = false; // Set entering flag to false
              mounted
                  ? setState(() {
                      currentQuery = controller
                          .text; // Update the current query with the new text value
                    })
                  : null;
            },
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(
                "assets/backgrounds/graffiti.png"), // Set background image for the container
            fit: BoxFit.cover,
            alignment: Alignment.bottomLeft,
            colorFilter: ColorFilter.mode(
              Colors.black
                  .withOpacity(0.5), // Apply opacity to the background image
              BlendMode.srcOver,
            ),
          ),
        ),
        child: currentQuery == null
            ? const SizedBox
                .shrink() // If the current query is null, display an empty SizedBox
            : SearchResultsList(
                query:
                    currentQuery!), // Display the search results based on the current query
      ),
    );
  }
}

class SearchResultsList extends StatefulWidget {
  final String query;

  const SearchResultsList({Key? key, required this.query}) : super(key: key);

  @override
  State<SearchResultsList> createState() => _SearchResultsList();
}

List<Map<String, dynamic>> results = [];

class _SearchResultsList extends State<SearchResultsList> {
  @override
  void initState() {
    super.initState();
  }

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
    commonLogger.v("searching users ${widget.query}");

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
              height: 82,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextButton(
                // Navigate to the profile page when the button is pressed
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(
                              userId: results[index]["user_id"],
                              navbar: false,
                            ))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    results[index]["avatar_id"] == null
                        ? const DefaultProfile(radius: 24)
                        : Flexible(
                            child: CachedNetworkImage(
                                imageUrl:
                                    '${Config.uri}/image/thumbnail/${results[index]["avatar_id"]}',
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                        baseColor: shimmer["base"]!,
                                        highlightColor: shimmer["highlight"]!,
                                        child: CircleAvatar(
                                          radius: 24,
                                          backgroundColor: swatch[900],
                                        )),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.contain),
                                      ),
                                    )),
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
                            Text(results[index]["username"] ?? "Channel",
                                style: TextStyle(
                                  color: swatch[301],
                                )),
                            Text(
                              results[index]["description"] ?? "",
                              style: TextStyle(color: swatch[601], height: 1.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
            )));
  }
}
