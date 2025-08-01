import "package:flutter/material.dart";
import "package:patinka/api/auth.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/login/config.dart";
import "package:patinka/login/layers/components/mainbutton.dart";
import "package:patinka/login/layers/components/pagebutton.dart";
import "package:patinka/login/layers/components/section.dart";
import "package:patinka/login/page_type.dart";

class SignupComponent extends StatefulWidget {
  const SignupComponent({required this.callback, super.key});
  final Function callback;

  @override
  State<SignupComponent> createState() =>
      _SignupComponent(); // Create a state object for the widget
}

class _SignupComponent extends State<SignupComponent> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final FocusNode focusNodeUsername = FocusNode();
  final FocusNode focusNodePassword = FocusNode();
  bool errorText = false;

  void handleSignup() async {
    // When the user taps the sign-in button, try to log them in
    try {
      // Call the login function with the username and password provided
      await AuthenticationAPI.signup(usernameController.text,
          passwordController.text, emailController.text);
      widget.callback(PageType.login);
    } catch (e) {
      mounted
          ? setState(() {
              errorText = true;
            })
          : null;
      commonLogger.e("An error has occured: $e");
    }
  }

  @override
  Widget build(final BuildContext context) => SizedBox(
      height: 684,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          InputSection(
            left: 59,
            top: 99,
            label: "Email",
            hint: "Enter your email",
            controller: emailController,
            // Move focus onto next text input
            callbackFunction: focusNodeUsername.requestFocus,
          ),
          InputSection(
            left: 59,
            top: 199,
            label: "Username",
            hint: "Enter your username",
            controller: usernameController,
            // Move focus onto next text input
            callbackFunction: focusNodePassword.requestFocus,
            focusNode: focusNodeUsername,
          ),
          InputSection(
            left: 59,
            top: 299,
            label: "Password",
            hint: "Enter your password",
            controller: passwordController,
            hidden: true,
            // Submit if keyboard enter is pressed
            callbackFunction: handleSignup,
            focusNode: focusNodePassword,
          ),
          errorText
              ? const Positioned(
                  top: 380,
                  left: 74,
                  child: Text(
                    "Signup Failed",
                    style: TextStyle(color: Colors.amber),
                  ))
              : const SizedBox.shrink(),
          PageButton(
            left: 87,
            top: 396,
            label: "Sign Up",
            callback: () => widget.callback(PageType.login),
          ),
          PageButton(
            right: 60,
            top: 396,
            label: "Forgot Password",
            callback: () => widget.callback(PageType.forgotPassword),
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
