import "package:flutter/material.dart";
import "package:patinka/api/support.dart";
import "package:patinka/misc/navbar_provider.dart";
import "package:patinka/social_media/user_reports/utils.dart";
import "package:provider/provider.dart";

class BlockButton extends StatelessWidget {
  const BlockButton({required this.blockUserId, super.key});
  final String blockUserId;
  //TODO: Check if is blocked
  @override
  Widget build(final BuildContext context) => ButtonBuilders.createTextButton(
        Icons.block,
        "Block User",
        Colors.red.shade700,
        () async {
          Navigator.pop(context);
          WidgetsBinding.instance.addPostFrameCallback((final _) {
            Provider.of<BottomBarVisibilityProvider>(context, listen: false)
                .hide();
          });
          SupportAPI.postBlockUser(blockUserId);
          // ModalBottomSheet.show(
          //     context: context,
          //     builder: (context) => BlockedBottomSheet(reportContentType: reportContentType),
          //     startSize: 0.65);
        },
      );
}
