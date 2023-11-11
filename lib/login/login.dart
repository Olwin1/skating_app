import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:patinka/login/config.dart';
import 'package:patinka/login/page_type.dart';
import './layers/layer_one.dart';
import './layers/layer_three.dart';
import './layers/layer_two.dart';

class LoginPage extends StatefulWidget {
  final bool loggedIn;
  final dynamic setLoggedIn;
  const LoginPage({Key? key, required this.loggedIn, this.setLoggedIn})
      : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  PageType previousPage = PageType.login;
  PageType currentPage = PageType.login;
  List<String> texts = ["Login"];

  void switchPage(PageType page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(currentPage.toString());

    return Scaffold(
        body: Stack(children: [
      ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: const AssetImage("assets/backgrounds/graffiti.png"),
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomLeft,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.4), BlendMode.srcOver)),
            ),
            padding: const EdgeInsets.all(16)),
      ),
      Stack(
        children: <Widget>[
          Positioned(
            top: 200,
            left: 0,
            child: TextMorphingAnimation(
              page: currentPage,
            ),
          ),
          const Positioned(top: 290, right: 0, bottom: 0, child: LayerOne()),
          const Positioned(top: 318, right: 0, bottom: 28, child: LayerTwo()),
          LayerThree(
            loggedIn: widget.loggedIn,
            setLoggedIn: widget.setLoggedIn,
            callback: switchPage,
            page: currentPage,
          ),
        ],
      )
    ]));
  }
}

class TextMorphingAnimationState extends State<TextMorphingAnimation> {
  double top = 0; // Initial top position

  // Update the top position based on the page
  void updateAlignment(PageType page) {
    setState(() {
      switch (page) {
        case PageType.signup:
          top = 200;
          break;
        case PageType.forgotPassword:
          top = 300; // Adjust this value as needed
          break;
        case PageType.verificationCode:
          top = 400; // Adjust this value as needed
          break;
        default:
          top = 200; // Adjust this value as needed
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Set the initial alignment based on the initial page
    updateAlignment(widget.page);
  }

  @override
  void didUpdateWidget(covariant TextMorphingAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the alignment when the widget receives a new page
    updateAlignment(widget.page);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedSwitcher(
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              duration: const Duration(seconds: 1),
              child: Text(
                getTextForPage(widget.page),
                key: ValueKey<PageType>(widget.page),
                style: TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.w900,
                  foreground: Paint()
                    ..color = titleColour
                    ..maskFilter = const MaskFilter.blur(
                      BlurStyle.solid,
                      10.0,
                    ),
                ),
              ),
            )));
  }

  String getTextForPage(PageType page) {
    switch (page) {
      case PageType.signup:
        return "Signup";
      case PageType.forgotPassword:
        return "Forgot Password";
      case PageType.verificationCode:
        return "Verify Email";
      default:
        return "Login";
    }
  }
}

class TextMorphingAnimation extends StatefulWidget {
  final PageType page;
  const TextMorphingAnimation({Key? key, required this.page}) : super(key: key);

  @override
  TextMorphingAnimationState createState() => TextMorphingAnimationState();
}
