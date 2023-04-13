import 'package:flutter/material.dart';
import 'package:skating_app/objects/user.dart';
import 'package:skating_app/social_media/private_messages/private_message_list.dart';
import 'post_widget.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../api/social.dart';

class HomePage extends StatelessWidget {
  // Create HomePage Class
  HomePage({Key? key}) : super(key: key);
  final _scrollController = ScrollController();

  @override // Override the existing widget build method
  Widget build(BuildContext context) {
    User user = User("1"); // Create user object with id of 1
    return Scaffold(
        appBar: AppBar(
          //systemOverlayStyle:
          //    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
          leading: TextButton(
            // Create a basic button

            child: const Image(
              // Set button to an image
              image: AssetImage("assets/placeholders/320x114.png"),
            ),
            onPressed: () {
              // When image pressed
              _scrollController.animateTo(0, //Scroll to top in 500ms
                  duration: const Duration(milliseconds: 500),
                  curve: Curves
                      .fastOutSlowIn); //Start scrolling fast then slow down when near top
            },
          ),
          title: const Text("Home"),
          backgroundColor: const Color.fromARGB(255, 185, 177, 102),
          actions: [
            const Spacer(
              // Move button to far right of screen
              flex: 1,
            ),
            TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PrivateMessageList(
                              user: user,
                              index: 1,
                            ))),
                child: Image.asset(
                    "assets/icons/message.png")) // Set Button To Message icon
          ],
        ),
        body: const Center(
            child:
                PostsListView()) /*update: )ListView.separated(
        controller: _scrollController,
        // Create a list of post widgets

        itemBuilder: (context, position) {
          // Function that will be looped to generate a widget
          return PostWidget(user: user, index: position);
        },
        separatorBuilder: (context, position) {
          // Function that will be looped in between each item
          return const SizedBox(
            // Create a seperator
            height: 20,
          );
        },
        itemCount: user
            .getPosts()
            .length, // Set count to the number of posts that there are
      )),*/
        );
  }
}

class PostsListView extends StatefulWidget {
  const PostsListView({
    super.key,
  }); //required this.update});
  //final ValueChanged<String> update;

  @override
  State<PostsListView> createState() => _PostsListViewState();
}

class _PostsListViewState extends State<PostsListView> {
  // PagingController manages the loading of pages as the user scrolls
  final PagingController<int, Object> _pagingController =
      PagingController(firstPageKey: 0);
  List<String> seenPosts = [];

  @override
  void initState() {
    // addPageRequestListener is called whenever the user scrolls near the end of the list
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

// Fetches the data for the given pageKey and appends it to the list of items
  Future<void> _fetchPage(int pageKey) async {
    try {
      // Loads the next page of images from the first album, skipping `pageKey` items and taking `_pageSize` items.
      final page = await getPosts(seenPosts);

      // Loops through each item in the page and adds its ID to the `seenPosts` list
      for (int i = 0; i < page.length; i++) {
        Map<String, dynamic> item = page[i] as Map<String, dynamic>;
        seenPosts.add(item['_id']);
        print(seenPosts);
      }

      // Determines if the page being fetched is the last page
      final isLastPage = page.isEmpty;

      if (isLastPage) {
        // If the page is the last page, call `appendLastPage` to add it to the list of items
        _pagingController.appendLastPage(page);
      } else {
        // If the page is not the last page, call `appendPage` to add the newly loaded items to the list of items
        _pagingController.appendPage(page, 0);
      }
    } catch (error) {
      // If an error occurs, sets the error state of the PagingController
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) => PagedListView<int, Object>(
        pagingController: _pagingController,
        // builderDelegate is responsible for creating the actual widgets to be displayed
        builderDelegate: PagedChildBuilderDelegate<Object>(
            // itemBuilder is called for each item in the list to create a widget for that item
            itemBuilder: (context, item, index) =>
                PostWidget(post: item, index: index)),
        padding: const EdgeInsets.all(
            8), // Add padding to list so doesn't overflow to sides of screen
      );

  @override
  void dispose() {
    // Disposes of the PagingController to free up resources
    _pagingController.dispose();
    super.dispose();
  }
}
