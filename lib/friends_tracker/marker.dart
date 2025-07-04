import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:patinka/api/config/config.dart";
import "package:patinka/misc/default_profile.dart";
import "package:patinka/swatch.dart";
import "package:shimmer/shimmer.dart";

class CustomMarker extends StatefulWidget {
  // Create FriendActivity widget
  const CustomMarker(
      {required this.userData, required this.sessionData, super.key}); // Take 2 arguments optional key and title of post
  final Map<String, dynamic> userData;
  final Map<String, dynamic> sessionData;

  @override
  State<CustomMarker> createState() =>
      _CustomMarker(); //Create state for widget
}

class _CustomMarker extends State<CustomMarker> {
  @override
  Widget build(final BuildContext context) {
    // Check if the sessionData contains any images
    if (widget.sessionData.containsKey("images") &&
        !widget.sessionData["images"].isEmpty) {
      // Return a Stack widget with two images
      return Stack(
        children: [
          // Show the first image as a larger circular image
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 8),
            child: CachedNetworkImage(
              imageUrl:
                  '${Config.uri}/image/${widget.sessionData["images"][0]}',
              imageBuilder: (final context, final imageProvider) => Container(
                width: 64.0,
                height: 64.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (final context, final url) => Shimmer.fromColors(
                  baseColor: shimmer["base"]!,
                  highlightColor: shimmer["highlight"]!,
                  child: CircleAvatar(
                    // Create a circular avatar icon
                    radius: 32, // Set radius to 36
                    backgroundColor: swatch[900],
                  )),
              errorWidget: (final context, final url, final error) => const Icon(Icons.error),
            ),
          ),
          // Show the user's avatar as a smaller circular image, if available
          widget.userData["avatar_id"] != null
              ? CachedNetworkImage(
                  imageUrl:
                      '${Config.uri}/image/widget.sessionData["images"][0]',
                  imageBuilder: (final context, final imageProvider) => Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (final context, final url) => Shimmer.fromColors(
                      baseColor: shimmer["base"]!,
                      highlightColor: shimmer["highlight"]!,
                      child: CircleAvatar(
                        // Create a circular avatar icon
                        radius: 16, // Set radius to 36
                        backgroundColor: swatch[900],
                      )),
                  errorWidget: (final context, final url, final error) => const Icon(Icons.error),
                )
              // If the user doesn't have an avatar, show a default placeholder image
              : const DefaultProfile(radius: 16)
        ],
      );
    }
    // If there are no images in sessionData, show the user's avatar as a larger circular image, if available
    return widget.userData["avatar_id"] != null
        ? CachedNetworkImage(
            imageUrl: '${Config.uri}/image/${widget.userData["avatar_id"]}',
            imageBuilder: (final context, final imageProvider) => Container(
              width: 64.0,
              height: 64.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
            placeholder: (final context, final url) => Shimmer.fromColors(
                baseColor: shimmer["base"]!,
                highlightColor: shimmer["highlight"]!,
                child: CircleAvatar(
                  // Create a circular avatar icon
                  radius: 32, // Set radius to 36
                  backgroundColor: swatch[900],
                )),
            errorWidget: (final context, final url, final error) => const Icon(Icons.error),
          )
        // If the user doesn't have an avatar, show a default placeholder image
        : Shimmer.fromColors(
            baseColor: shimmer["base"]!,
            highlightColor: shimmer["highlight"]!,
            child: CircleAvatar(
              // Create a circular avatar icon
              radius: 32, // Set radius to 36
              backgroundColor: swatch[900],
            ));
  }
}
