import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:patinka/social_media/post_widget.dart';
import 'package:patinka/swatch.dart';

void showNotification(context) {
  InAppNotification.show(child: const NotificationBody(count: 1, minHeight: 34,), context: context);
}

class NotificationBody extends StatelessWidget {
  final int count;
  final double minHeight;

  const NotificationBody({
    super.key,
    this.count = 0,
    this.minHeight = 0.0,
  });

  @override
  Widget build(BuildContext context) {
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
              Padding(padding: EdgeInsets.all(8), child: Row(
                children: [
                  Container(margin: EdgeInsets.symmetric(horizontal: 8), height:48, width:48, child:
                  Avatar(user: "0")),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Olwin1",
                        overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500, color: swatch[101])),
                      Text(
                        "Bro what are you even doing i literally cant even",
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15),
                      )
                    ],
                  ),),
                ],
              ),),
                  SizedBox(height: 15,),
              AnimatedLine()
              //Container(color: Colors.green, width: double.maxFinite, height: 3)
            ])));
  }
}

class AnimatedLine extends StatefulWidget {
  const AnimatedLine({super.key});

  @override
  _AnimatedLineState createState() => _AnimatedLineState();
}

class _AnimatedLineState extends State<AnimatedLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
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
