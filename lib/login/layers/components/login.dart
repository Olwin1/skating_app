import 'package:flutter/material.dart';
import 'package:patinka/login/layers/components/pagebutton.dart';
import 'package:patinka/login/layers/components/section.dart';
import '../../../api/auth.dart';
import '../../../api/config.dart';
import '../../../api/social.dart';
import '../../../common_logger.dart';
import '../../config.dart';
import '../../page_type.dart';
import 'mainbutton.dart';

class LoginComponent extends StatefulWidget {
  const LoginComponent(
      {Key? key,
      required this.loggedIn,
      this.setLoggedIn,
      required this.callback})
      : super(key: key);
  final bool loggedIn;
  final dynamic setLoggedIn;
  final Function callback;

  @override
  State<LoginComponent> createState() =>
      _LoginComponent(); // Create a state object for the widget
}

class _LoginComponent extends State<LoginComponent> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool errorText = false;
  void loadHome() {
    widget.setLoggedIn(true);
  }

  void handleSignin() async {
    // When the user taps the sign-in button, try to log them in
    try {
      // Call the login function with the username and password provided
      var res = await login(usernameController.text, passwordController.text);
      // If login is successful, save the user's token to local storage
      await storage.setToken(res);
      SocialAPI.getUser("0").then((value) => storage.setId(value["user_id"]));
      // Load the home screen
      loadHome();
      commonLogger.d("Result: $res");
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
  Widget build(BuildContext context) {
    return SizedBox(
        height: 584,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: <Widget>[
            InputSection(
              left: 59,
              top: 99,
              label: "Username",
              hint: "Enter your username",
              controller: usernameController,
            ),
            InputSection(
              left: 59,
              top: 199,
              label: "Password",
              hint: "Enter your password",
              controller: passwordController,
              hidden: true,
            ),
            errorText
                ? const Positioned(
                    top: 280,
                    left: 74,
                    child: Text(
                      "Incorrect Password",
                      style: TextStyle(color: Colors.amber),
                    ))
                : const SizedBox.shrink(),
            PageButton(
              left: 87,
              top: 296,
              label: "Signup",
              callback: () => widget.callback(PageType.signup),
            ),
            PageButton(
              right: 60,
              top: 296,
              label: "Forgot Password",
              callback: () => widget.callback(PageType.forgotPassword),
            ),
            MainButton(
              top: 365,
              label: "Sign In",
              callback: handleSignin,
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
