import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:patinka/api/config.dart";
import "package:patinka/misc/default_profile.dart";
import "package:patinka/profile/profile_page/connections_list.dart";
import "package:patinka/swatch.dart";
import "package:shimmer/shimmer.dart";

class ProfileBanner extends StatelessWidget {
  const ProfileBanner({required this.user, super.key, this.avatar});
  final String? avatar;
  final Map<String, dynamic>? user;
  @override
  Widget build(final BuildContext context) => Row(children: [
        // Circle avatar
        Padding(
          padding: const EdgeInsets.all(8), // Add padding
          child: avatar == null
              ? Shimmer.fromColors(
                  baseColor: shimmer["base"]!,
                  highlightColor: shimmer["highlight"]!,
                  child: Shimmer.fromColors(
                      baseColor: shimmer["base"]!,
                      highlightColor: shimmer["highlight"]!,
                      child: CircleAvatar(
                        // Create a circular avatar icon
                        radius: 36, // Set radius to 36
                        backgroundColor: swatch[900],
                      )))
              : avatar != "default"
                  ? CachedNetworkImage(
                      placeholder: (final context, final url) =>
                          Shimmer.fromColors(
                              baseColor: shimmer["base"]!,
                              highlightColor: shimmer["highlight"]!,
                              child: CircleAvatar(
                                // Create a circular avatar icon
                                radius: 36, // Set radius to 36
                                backgroundColor: swatch[900],
                              )),
                      imageUrl: '${Config.uri}/image/${user!["avatar_id"]}',
                      imageBuilder: (final context, final imageProvider) =>
                          Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape
                              .circle, // Set the shape of the container to a circle
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.contain),
                        ),
                      ),
                      httpHeaders: const {"thumbnail": "true"},
                    )
                  : const DefaultProfile(radius: 36),
        ),
        // Column to display the number of friends

        ConnectionLists(
          user: user,
        ),
      ]);
}
