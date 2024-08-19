import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:patinka/api/config.dart';
import 'package:patinka/misc/default_profile.dart';
import 'package:patinka/swatch.dart';
import 'package:shimmer/shimmer.dart';

import 'connections_list.dart';

class ProfileBanner extends StatelessWidget {
  final String? avatar;
  final Map<String, dynamic>? user;

  const ProfileBanner({super.key, this.avatar, required this.user});
  @override
  Widget build(BuildContext context) {
    // Row to display the number of friends, followers, and following
    return
        Row(children: [
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
                        placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: shimmer["base"]!,
                            highlightColor: shimmer["highlight"]!,
                            child: CircleAvatar(
                              // Create a circular avatar icon
                              radius: 36, // Set radius to 36
                              backgroundColor: swatch[900],
                            )),
                        imageUrl: '${Config.uri}/image/${user!["avatar_id"]}',
                        imageBuilder: (context, imageProvider) => Container(
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
  
}