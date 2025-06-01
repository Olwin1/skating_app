import "dart:math" as math;

import "package:flutter/material.dart";
import "package:in_app_notification/in_app_notification.dart";
import "package:patinka/api/messages.dart";
import "package:patinka/api/social.dart";
import "package:patinka/misc/notifications/animated_line.dart";
import "package:patinka/social_media/post_widget.dart";
import "package:patinka/social_media/private_messages/private_message.dart";
import "package:patinka/social_media/utils/current_channel.dart";
import "package:patinka/swatch.dart";

const int dur = 3;
Map<String, dynamic>? user;
Map<String, dynamic>? channel;
void handleTap(
    final BuildContext context,
    final Map<String, dynamic>? user,
    final Map<String, dynamic>? channel,
    final String currentUser,
    final String channelId) async {
  // Navigate to PrivateMessage page when the list item is clicked
  final Map<String, dynamic> userV =
      user ?? await SocialAPI.getUser(currentUser);
  final Map<String, dynamic> channelV =
      channel ?? await MessagesAPI.getChannel(channelId);
  if (context.mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (final context) => PrivateMessage(
          initSelf: false,
          channel: channelV,
          user: userV,
          currentUser: currentUser,
        ),
      ),
    );
  }
}

void showNotification(final BuildContext context,
    final Map<String, dynamic> data, final String currentUser) {
  if (CurrentMessageChannel.instance.getTopStack == data["channel"]) {
    return;
  }
  InAppNotification.show(
      onTap: () =>
          handleTap(context, user, channel, currentUser, data["channel"]),
      child: NotificationBody(
        count: 1,
        minHeight: 34,
        senderId: data["sender"],
        content: data["content"],
        channelId: data["channel"],
        currentUser: currentUser,
        duration: dur
      ),
      context: context,
      duration: const Duration(seconds: dur));
}

class NotificationBody extends StatelessWidget {
  const NotificationBody(
      {required this.senderId,
      required this.content,
      required this.channelId,
      required this.currentUser,
      required this.duration,
      super.key,
      this.count = 0,
      this.minHeight = 0.0});
  final int count;
  final double minHeight;
  final String senderId;
  final String content;
  final String channelId;
  final String currentUser;
  final int duration;

  void init() {
    // Get the current user's identifier and set the state

    SocialAPI.getUser(currentUser).then((final value) => user = value);
    MessagesAPI.getChannel(channelId).then((final value) => channel = value);
  }

  @override
  Widget build(final BuildContext context) {
    init();

    final minHeight = math.min(
      this.minHeight,
      MediaQuery.of(context).size.height,
    );
    return ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Container(
            clipBehavior: Clip.hardEdge,
            margin: const EdgeInsets.only(left: 12, right: 12, top: 18),
            decoration: BoxDecoration(
                color: const Color(0xff004400),
                borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        height: 48,
                        width: 48,
                        child: Avatar(user: senderId)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Olwin1",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: swatch[101])),
                          Text(
                            content,
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              AnimatedLine(duration: duration)
              //Container(color: Colors.green, width: double.maxFinite, height: 3)
            ])));
  }
}
