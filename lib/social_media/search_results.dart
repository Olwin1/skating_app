import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skating_app/api/social.dart';
import 'package:skating_app/profile/profile_page.dart';
import '../api/config.dart';
import '../swatch.dart';

bool entering = false;

class SearchResults extends StatefulWidget {
  final String query;

  // Create HomePage Class
  const SearchResults({Key? key, required this.query})
      : super(key: key); // Take 2 arguments optional key and title of post
  @override
  State<SearchResults> createState() =>
      _SearchResults(); //Create state for widget
}

class _SearchResults extends State<SearchResults> {
  TextEditingController controller = TextEditingController();
  String? currentQuery;
  @override
  void initState() {
    currentQuery = widget.query;
    controller.text = currentQuery!;
    super.initState();
  }

  @override // Override existing build method
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Container(
        padding: const EdgeInsets.all(8),
        child: TextField(
          controller: controller,
          showCursor: false,
          maxLines: 1,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
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
            entering = false;
            setState(() {
              currentQuery = controller.text;
            });
          },
        ),
      )),
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: const AssetImage("assets/backgrounds/graffiti.png"),
                fit: BoxFit.cover,
                alignment: Alignment.bottomLeft,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5), BlendMode.srcOver)),
          ),
          child: currentQuery == null
              ? const SizedBox.shrink()
              : SearchResultsList(query: currentQuery!)),
    );
  }
}

class SearchResultsList extends StatefulWidget {
  final String query;

  // Create HomePage Class
  const SearchResultsList({Key? key, required this.query})
      : super(key: key); // Take 2 arguments optional key and title of post
  @override
  State<SearchResultsList> createState() =>
      _SearchResultsList(); //Create state for widget
}

class _SearchResultsList extends State<SearchResultsList> {
  @override
  void initState() {
    super.initState();
  }

  TextEditingController controller = TextEditingController();
  List<Map<String, dynamic>> results = [];

  @override // Override existing build method
  Widget build(BuildContext context) {
    if (entering) {
      return Results(results: results);
    }
    entering = true;
    searchUsers(widget.query).then((value) => setState(
          () {
            results = value;
          },
        ));

    return Results(
      results: results,
    );
  }
}

class Results extends StatelessWidget {
  const Results({super.key, required this.results});
  final List<Map<String, dynamic>> results;

  @override // Override existing build method
  Widget build(BuildContext context) {
    print(results);
    print("erer");
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
              margin: const EdgeInsets.symmetric(
                  horizontal: 8), // Add padding so doesn't touch edges
              padding: const EdgeInsets.symmetric(
                  vertical: 8), // Add padding so doesn't touch edges
              child: TextButton(
                // Make list widget clickable
                onPressed: () => Navigator.push(
                    // When button pressed
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(
                              userId: results[index]["_id"],
                              navbar: false,
                            ))), //When list widget clicked
                child: Row(
                  // Create a row
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Add List image to one row and buttons to another
                    results[index]["avatar"] == null
                        // If there is no cached user information or avatar image, use a default image
                        ? Shimmer.fromColors(
                            baseColor: const Color(0x66000000),
                            highlightColor: const Color(0xff444444),
                            child: CircleAvatar(
                              // Create a circular avatar icon
                              radius: 36, // Set radius to 36
                              backgroundColor: swatch[900]!,
                              // backgroundImage: AssetImage(
                              //     "assets/placeholders/default.png"), // Set avatar to placeholder images
                            ))
                        // If there is cached user information and an avatar image, use the cached image
                        : Flexible(
                            child: CachedNetworkImage(
                                imageUrl:
                                    '${Config.uri}/image/thumbnail/${results[index]["avatar"]}',
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                        baseColor: const Color(0x66000000),
                                        highlightColor: const Color(0xff444444),
                                        child: CircleAvatar(
                                          // Create a circular avatar icon
                                          radius: 36, // Set radius to 36
                                          backgroundColor: swatch[900]!,
                                          // backgroundImage: AssetImage(
                                          //     "assets/placeholders/default.png"), // Set avatar to placeholder images
                                        )),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape
                                            .circle, // Set the shape of the container to a circle
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.contain),
                                      ),
                                    )),
                          ),
                    const Padding(
                        padding: EdgeInsets.only(
                            left: 16)), // Space between avatar and text
                    Flexible(
                      flex: 6,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Create a column aligned to the left
                            const Padding(
                              //Add padding to the top to move the text down a bit
                              padding: EdgeInsets.only(top: 10),
                            ),
                            Text(
                                //Message target's Name
                                results[index]["username"] ?? "Channel",
                                style: TextStyle(
                                  color: swatch[301],
                                )),
                            Text(results[index]["_id"],
                                style: TextStyle(
                                    color:
                                        swatch[601], // Set colour to light grey
                                    height:
                                        1.5)), // Last message sent from user
                          ]),
                    ),
                  ],
                ),
              ),
            )));
  }
}
