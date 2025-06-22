import "package:flutter/material.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/login/config.dart";
import "package:patinka/login/layers/components/mainbutton.dart";
import "package:patinka/login/layers/components/pagebutton.dart";
import "package:patinka/login/layers/components/section.dart";
import "package:patinka/login/page_type.dart";

class ForgotComponent extends StatelessWidget {
  const ForgotComponent({required this.callback, super.key});
  final Function callback;

  void handleForgot() {
    commonLogger.d("Handle Forgot");
  }

  @override
  Widget build(final BuildContext context) => SizedBox(
      height: 484,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          InputSection(
            left: 59,
            top: 169,
            label: "Email",
            hint: "Enter your email",
            controller: TextEditingController(),
            // Submit if keyboard enter is pressed
            callbackFunction: handleForgot,
          ),
          PageButton(
            left: 87,
            top: 296,
            label: "Sign In",
            callback: () => callback(PageType.login),
          ),
          PageButton(
            right: 60,
            top: 296,
            label: "Signup",
            callback: () => callback(PageType.signup),
          ),
          MainButton(
            top: 365,
            label: "Reset Password",
            callback: handleForgot,
          ),
          Positioned(
              top: 432,
              left: 59,
              child: Container(
                height: 0.5,
                width: 310,
                color: inputBorder,
              )),
        ],
      ));
}
