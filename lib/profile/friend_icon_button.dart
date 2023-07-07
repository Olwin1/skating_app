import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  bool loading = false;
  bool changed = false;
  String friend = "no"; // can be no, yes, maybe
  _handlePressed() {
    if (!loading) {
      loading = true;
      if (friend == "maybeIncoming") {
        friendUserRequest(widget.user!["_id"], true).then((value) => {
              // Logs the response from `followUser`
              commonLogger.v("Friend accept success $value"),
              // If follow request is successful, update `type` to "requested"
              mounted ? setState(() => friend = "yes") : null,
              loading = false
            });
      } else if (friend != "no" && friend != "self") {
        unfriendUser(widget.user!["_id"]).then((value) => {
              // Logs the response from `followUser`
              commonLogger.v("Unfriend success $value"),
              // If follow request is successful, update `type` to "requested"
              mounted ? setState(() => friend = "no") : null, loading = false
            });
      } else if (friend != "self") {
        friendUser(widget.user!["_id"]).then((value) => {
              // Logs the response from `followUser`
              commonLogger.v("Friend success $value"),
              // If follow request is successful, update `type` to "requested"
              mounted ? setState(() => friend = "maybeOutgoing") : null,
              loading = false
            });
      }
    }
  }

  Widget getIcon() {
    switch (friend) {
      case "no":
        return SvgPicture.asset(
          "assets/icons/profile/add_friend.svg",
          fit: BoxFit.fitHeight,
          width: 32,
          alignment: Alignment.centerLeft,
          colorFilter: ColorFilter.mode(swatch[501]!, BlendMode.srcIn),
        );
      case "yes":
        return SvgPicture.asset(
          "assets/icons/profile/friends.svg",
          fit: BoxFit.fitHeight,
          width: 32,
          alignment: Alignment.centerLeft,
          colorFilter: const ColorFilter.mode(
              Color.fromARGB(255, 116, 0, 81), BlendMode.srcIn),
        );
      case "self":
        return const SizedBox.shrink();
      case "maybeOutgoing":
        return SvgPicture.asset(
          "assets/icons/profile/add_friend.svg",
          fit: BoxFit.fitHeight,
          width: 32,
          alignment: Alignment.centerLeft,
          colorFilter: ColorFilter.mode(swatch[600]!, BlendMode.srcIn),
        );
      case "maybeIncoming":
        return SvgPicture.asset(
          "assets/icons/profile/add_friend.svg",
          fit: BoxFit.fitHeight,
          width: 32,
          alignment: Alignment.centerLeft,
          colorFilter: ColorFilter.mode(swatch[901]!, BlendMode.srcIn),
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
