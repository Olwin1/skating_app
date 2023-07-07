import 'package:flutter/material.dart';
import 'package:skating_app/api/connections.dart';
import 'package:skating_app/api/messages.dart';
import 'package:skating_app/common_logger.dart';

import '../swatch.dart';

class FriendIconButton extends StatefulWidget {
  final Map<String, dynamic>? user;

  // StatefulWidget that defines an options menu
  const FriendIconButton({super.key, required this.user});

  @override
  State<FriendIconButton> createState() => _FriendIconButtonState();
}

class _FriendIconButtonState extends State<FriendIconButton> {
  bool changed = false;
  String friend = "no"; // can be no, yes, maybe
  _handlePressed() {
    if (friend == "maybeIncoming") {
      friendUserRequest(widget.user!["_id"], true).then((value) => {
            // Logs the response from `followUser`
            commonLogger.v("Friend accept success $value"),
            // If follow request is successful, update `type` to "requested"
            mounted ? setState(() => friend = "yes") : null
          });
    } else if (friend != "no") {
      unfriendUser(widget.user!["_id"]).then((value) => {
            // Logs the response from `followUser`
            commonLogger.v("Unfriend success $value"),
            // If follow request is successful, update `type` to "requested"
            mounted ? setState(() => friend = "no") : null
          });
    } else {
      friendUser(widget.user!["_id"]).then((value) => {
            // Logs the response from `followUser`
            commonLogger.v("Friend success $value"),
            // If follow request is successful, update `type` to "requested"
            mounted ? setState(() => friend = "maybeOutgoing") : null
          });
    }
  }

  Widget getIcon() {
    switch (friend) {
      case "no":
        return Icon(
          Icons.precision_manufacturing_outlined,
          color: swatch[401],
        );
      case "yes":
        return Icon(
          Icons.ac_unit,
          color: swatch[401],
        );
      case "self":
        return Icon(
          Icons.accessible_forward,
          color: swatch[401],
        );
      case "maybeOutgoing":
        return Icon(
          Icons.access_alarm_sharp,
          color: swatch[401],
        );
      case "maybeIncoming":
        return Icon(
          Icons.adb_sharp,
          color: swatch[401],
        );
      default:
        return const Icon(Icons.abc);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!changed && widget.user != null) {
      if (widget.user != null) {
        commonLogger.w("USer is availd");
        getUserId().then((value) {
          if (value == widget.user!["_id"]) {
            setState(() {
              friend = "self";
            });
          } else {
            doesFriend(widget.user!["_id"]).then((value) => {
                  commonLogger.i(value),
                  setState(
                    () => value[0]
                        ? value[1]
                            ? value[2]
                                ? friend = "maybeOutgoing"
                                : friend = "maybeIncoming"
                            : friend = "yes"
                        : null,
                  ),
                  commonLogger.w(value)
                });
          }
        });
      }
      changed = true;
    }
    commonLogger.w(friend);
    return Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
            color: Color.fromARGB(125, 0, 0, 0),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: TextButton(onPressed: () => _handlePressed(), child: getIcon()));
  }
}
