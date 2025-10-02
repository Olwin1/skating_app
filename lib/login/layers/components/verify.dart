import "package:flutter/material.dart";
import "package:patinka/api/auth.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/login/config.dart";
import "package:patinka/login/layers/components/components/resend.dart";
import "package:patinka/login/layers/components/mainbutton.dart";
import "package:patinka/login/layers/components/section.dart";
import "package:patinka/login/page_type.dart";
import "package:patinka/misc/notifications/notification_types.dart";

/// A widget that provides a verification input and button for confirming
/// the user's email verification code.
///
/// Once the verification succeeds, it will navigate the user back to the login page.
/// If verification fails, it will show an error notification.
///
/// Usage:
/// ```dart
/// VerifyComponent(
///   callback: (PageType page) {
///     // Handle page navigation here
///   },
/// )
/// ```
class VerifyComponent extends StatefulWidget {
  /// Creates a [VerifyComponent].
  ///
  /// The [callback] is triggered after verification to switch to the login page
  /// or handle navigation logic.
  const VerifyComponent(
      {required this.callback, required this.userId, super.key});

  /// Callback function to change the current page (e.g., to login after verification).
  final Function callback;

  final String? userId;

  @override
  State<VerifyComponent> createState() => _VerifyComponentState();
}

class _VerifyComponentState extends State<VerifyComponent> {
  /// Focus node for managing focus on the password input (reserved for navigation).
  final FocusNode focusNodePassword = FocusNode();

  /// Controller for handling user input of the verification code.
  final TextEditingController verificationCodeController =
      TextEditingController();

  /// Sends the verification request to the server and handles the response.
  ///
  /// - On success: Shows a success notification and triggers the [widget.callback]
  ///   with [PageType.login].
  /// - On failure: Shows an error notification.
  void handleVerify() async {
    commonLogger.d("Sending verify request to server");

    // Call the authentication API to verify the email code
    final bool verificationResult = await AuthenticationAPI.verifyEmail(
        verificationCodeController.text, widget.userId);

    if (verificationResult && mounted) {
      // Success notification
      PopupNotificationManager.showSuccessNotification(
        context,
        "Email Successfully Verified.",
      );

      // Navigate to the login page after successful verification
      widget.callback(PageType.login);
    } else {
      // Failure notification
      if (mounted) {
        PopupNotificationManager.showErrorNotification(
          context,
          "Invalid or Expired Verification Code.",
        );
      }
    }
  }

  @override
  Widget build(final BuildContext context) => SizedBox(
        height: 584,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: <Widget>[
            /// Input section for entering the verification code
            InputSection(
              left: 59,
              top: 99,
              label: "Verification Code",
              hint: "Enter your e-mail verification code",
              controller: verificationCodeController,
              // Move focus to the next text input (currently password focus node)
              callbackFunction: focusNodePassword.requestFocus,
            ),

            /// Main verification button
            MainButton(
              top: 296,
              label: "Verify",
              callback: handleVerify,
            ),
            Positioned(
                top: 316, child: CountdownButton(userId: widget.userId!)),

            /// Divider line under the verification section
            Positioned(
              top: 432,
              left: 59,
              child: Container(
                height: 0.5,
                width: 310,
                color: inputBorder,
              ),
            ),
          ],
        ),
      );
}
