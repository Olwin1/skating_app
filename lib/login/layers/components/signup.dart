import 'package:flutter/material.dart';
import 'package:patinka/login/layers/components/pagebutton.dart';
import 'package:patinka/login/layers/components/section.dart';
import '../../config.dart';
import '../../page_type.dart';
import 'mainbutton.dart';

class SignupComponent extends StatelessWidget {
  const SignupComponent({super.key, required this.callback});
  final Function callback;
  void handleSignup() {
    print("signuphandle");
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 684,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: <Widget>[
            InputSection(
              left: 59,
              top: 99,
              label: "Email",
              hint: "Enter your email",
              controller: TextEditingController(),
            ),
            InputSection(
              left: 59,
              top: 199,
              label: "Username",
              hint: "Enter your username",
              controller: TextEditingController(),
            ),
            InputSection(
              left: 59,
              top: 299,
              label: "Password",
              hint: "Enter your password",
              controller: TextEditingController(),
            ),
            PageButton(
              left: 87,
              top: 396,
              label: "Sign In",
              callback: () => callback(PageType.login),
            ),
            PageButton(
              right: 60,
              top: 396,
              label: "Forgot Password",
              callback: () => callback(PageType.forgotPassword),
            ),
            MainButton(
              top: 465,
              label: "Sign In",
              callback: handleSignup,
            ),
            Positioned(
                top: 532,
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
