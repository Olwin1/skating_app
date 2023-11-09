import 'package:flutter/material.dart';
import 'package:patinka/login/layers/components/pagebutton.dart';
import 'package:patinka/login/layers/components/section.dart';
import '../../config.dart';
import '../../page_type.dart';
import 'mainbutton.dart';

class ForgotComponent extends StatelessWidget {
  const ForgotComponent({super.key, required this.callback});
  final Function callback;

  void handleForgot() {
    print("foorgoithandle");
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
}
