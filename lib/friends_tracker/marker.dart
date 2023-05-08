import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skating_app/api/config.dart';

class CustomMarker extends StatefulWidget {
  // Create FriendActivity widget
  const CustomMarker(
      {Key? key, required this.userData, required this.sessionData})
      : super(key: key); // Take 2 arguments optional key and title of post
  final Map<String, dynamic> userData;
  final Map<String, dynamic> sessionData;

  @override
  State<CustomMarker> createState() =>
      _CustomMarker(); //Create state for widget
}

class _CustomMarker extends State<CustomMarker> {
  @override
  Widget build(BuildContext context) {
    print('${Config.uri}/image/${widget.sessionData["images"][0]}');
    // Check if the sessionData contains any images
    if (!widget.sessionData["images"].isEmpty) {
      // Return a Stack widget with two images
      return Stack(
        children: [
          // Show the first image as a larger circular image
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 8),
            child: CachedNetworkImage(
              imageUrl:
                  '${Config.uri}/image/${widget.sessionData["images"][0]}',
              imageBuilder: (context, imageProvider) => Container(
                width: 64.0,
                height: 64.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          // Show the user's avatar as a smaller circular image, if available
          widget.userData["avatar"] != null
              ? CachedNetworkImage(
                  imageUrl:
                      '${Config.uri}/image/widget.sessionData["images"][0]',
                  imageBuilder: (context, imageProvider) => Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                )
              // If the user doesn't have an avatar, show a default placeholder image
              : CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: ClipOval(
                      child: Image.asset("assets/placeholders/default.png"),
                    ),
                  ))
        ],
      );
    }
    // If there are no images in sessionData, show the user's avatar as a larger circular image, if available
    return widget.userData["avatar"] != null
        ? CachedNetworkImage(
            imageUrl: '${Config.uri}/image/widget.sessionData["images"][0]',
            imageBuilder: (context, imageProvider) => Container(
              width: 64.0,
              height: 64.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )
        // If the user doesn't have an avatar, show a default placeholder image
        : CircleAvatar(
            backgroundColor: Colors.transparent,
            child: SizedBox(
              width: 64,
              height: 64,
              child: ClipOval(
                child: Image.asset("assets/placeholders/default.png"),
              ),
            ));
  }
}