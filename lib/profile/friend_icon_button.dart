import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:patinka/api/connections.dart';
import 'package:patinka/api/messages.dart';
import 'package:patinka/common_logger.dart';

import '../swatch.dart';

class FriendIconButton extends StatefulWidget {
  final Map<String, dynamic>? user;

  // StatefulWidget that defines an options menu
  const FriendIconButton({super.key, required this.user});

  @override
  State<FriendIconButton> createState() => _FriendIconButtonState();
}

enum FriendState { yes, requestedOutgoing, requestedIncoming, no, self }

class _FriendIconButtonState extends State<FriendIconButton> {
  bool loading = false;
  bool changed = false;
  FriendState friend = FriendState.no; // can be no, yes, maybe
  void _handlePressed() {
    if (!loading) {
      loading = true;
      if (friend == FriendState.requestedIncoming) {
        ConnectionsAPI.friendUserRequest(widget.user!["user_id"], true)
            .then((value) => {
                  // Logs the response from `followUser`
                  commonLogger.v("Friend accept success $value"),
                  // If follow request is successful, update `type` to "requested"
                  mounted ? setState(() => friend = FriendState.yes) : null,
                  loading = false
                });
      } else if (friend != FriendState.no && friend != FriendState.self) {
        ConnectionsAPI.unfriendUser(widget.user!["user_id"]).then((value) => {
              // Logs the response from `followUser`
              commonLogger.v("Unfriend success $value"),
              // If follow request is successful, update `type` to "requested"
              mounted ? setState(() => friend = FriendState.no) : null,
              loading = false
            });
      } else if (friend != FriendState.self) {
        ConnectionsAPI.friendUser(widget.user!["user_id"]).then((value) => {
              // Logs the response from `followUser`
              commonLogger.v("Friend success $value"),
              // If follow request is successful, update `type` to "requested"
              mounted
                  ? setState(() => friend = FriendState.requestedOutgoing)
                  : null,
              loading = false
            });
      }
    }
  }

  Widget getIcon() {
    switch (friend) {
      case FriendState.no:
        return SvgPicture.asset(
          "assets/icons/profile/add_friend.svg",
          fit: BoxFit.fitHeight,
          width: 32,
          alignment: Alignment.centerLeft,
          colorFilter: ColorFilter.mode(swatch[501]!, BlendMode.srcIn),
        );
      case FriendState.yes:
        return SvgPicture.asset(
          "assets/icons/profile/friends.svg",
          fit: BoxFit.fitHeight,
          width: 32,
          alignment: Alignment.centerLeft,
          colorFilter: const ColorFilter.mode(
              Color.fromARGB(255, 116, 0, 81), BlendMode.srcIn),
        );
      case FriendState.self:
        return const SizedBox.shrink();
      case FriendState.requestedOutgoing:
        return SvgPicture.asset(
          "assets/icons/profile/add_friend.svg",
          fit: BoxFit.fitHeight,
          width: 32,
          alignment: Alignment.centerLeft,
          colorFilter: ColorFilter.mode(swatch[600]!, BlendMode.srcIn),
        );
      case FriendState.requestedIncoming:
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
        MessagesAPI.getUserId().then((value) {
          if (value == widget.user!["user_id"]) {
            setState(() {
              friend = FriendState.self;
            });
          } else {
            FriendState val = FriendState.no;
            ConnectionsAPI.doesFriend(widget.user!["user_id"]).then((value) => {
                  commonLogger.i(value),
                  if (!value["friends"])
                    {
                      if (value["requestedOutgoing"] != null)
                        {val = FriendState.requestedOutgoing}
                      else if (value["requestedIncoming"] != null)
                        {val = FriendState.requestedIncoming}
                    }
                  else
                    {val = FriendState.yes},
                  setState(() => friend = val),
                  commonLogger.w(value)
                });
          }
        });
      }
      changed = true;
    }
    commonLogger.w(friend);
    return friend == FriendState.self
        ? const SizedBox.shrink()
        : Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
                color: Color.fromARGB(125, 0, 0, 0),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: TextButton(
                onPressed: () => _handlePressed(), child: getIcon()));
  }
}
