import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:patinka/api/messages.dart';
import 'package:patinka/api/social.dart';
import 'package:patinka/social_media/post_widget.dart';
import 'package:patinka/swatch.dart';

import 'private_message.dart';

int dur = 3;
Map<String, dynamic>? user;
Map<String, dynamic>? channel;
void handleTap(context, Map<String, dynamic>? user,
    Map<String, dynamic>? channel, String currentUser, String channelId) async {
  // Navigate to PrivateMessage page when the list item is clicked
  Map<String, dynamic>? userV = user ?? await SocialAPI.getUser(currentUser);
  Map<String, dynamic>? channelV =
      channel ?? await MessagesAPI.getChannel(channelId);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PrivateMessage(
        index: 1,
        channel: channelV,
        user: userV,
        currentUser: currentUser,
      ),
    ),
  );
}

void showNotification(context, Map<String, dynamic> data, String currentUser) {
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
      ),
      context: context,
      duration: Duration(seconds: dur));
}

class NotificationBody extends StatelessWidget {
  final int count;
  final double minHeight;
  final String senderId;
  final String content;
  final String channelId;
  final String currentUser;

  NotificationBody(
      {super.key,
      this.count = 0,
      this.minHeight = 0.0,
      required this.senderId,
      required this.content,
      required this.channelId,
      required this.currentUser});

  void init() {
    // Get the current user's identifier and set the state

    SocialAPI.getUser(currentUser).then((value) => user = value);
    MessagesAPI.getChannel(channelId).then((value) => channel = value);
  }

  @override
  Widget build(BuildContext context) {
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
              const AnimatedLine()
              //Container(color: Colors.green, width: double.maxFinite, height: 3)
            ])));
  }
}

class AnimatedLine extends StatefulWidget {
  const AnimatedLine({super.key});

  @override
  AnimatedLineState createState() => AnimatedLineState();
}

class AnimatedLineState extends State<AnimatedLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: dur + 1),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: 2, // Height of the line
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: _animation.value,
          child: Container(
            color: swatch[601],
          ),
        ),
      ),
    );
  }
}
