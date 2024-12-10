import "package:flutter/material.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/login/config.dart";
import "package:patinka/login/layers/components/mainbutton.dart";
import "package:patinka/login/layers/components/pagebutton.dart";
import "package:patinka/login/layers/components/section.dart";
import "package:patinka/login/page_type.dart";

class VerifyComponent extends StatelessWidget {
  const VerifyComponent({required this.callback, super.key});
  final Function callback;
  void handleVerify() {
    commonLogger.d("Handle Verify");
  }

  @override
  Widget build(final BuildContext context) => SizedBox(
        height: 584,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: <Widget>[
            InputSection(
              left: 59,
              top: 99,
              label: "Username",
              hint: "Enter your username",
              controller: TextEditingController(),
            ),
            InputSection(
              left: 59,
              top: 199,
              label: "Password",
              hint: "Enter your password",
              controller: TextEditingController(),
            ),
            PageButton(
              left: 87,
              top: 296,
              label: "Signup",
              callback: () => callback(PageType.signup),
            ),
            PageButton(
              right: 60,
              top: 296,
              label: "Forgot Password",
              callback: () => callback(PageType.forgotPassword),
            ),
            MainButton(
              top: 365,
              label: "Sign In",
              callback: handleVerify,
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
