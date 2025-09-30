import "dart:ui";

import "package:flutter/material.dart";
import "package:patinka/api/image/image.dart";
import "package:patinka/common_logger.dart";
import "package:patinka/login/config.dart";
import "package:patinka/login/layers/layer_one.dart";
import "package:patinka/login/layers/layer_three.dart";
import "package:patinka/login/layers/layer_two.dart";
import "package:patinka/login/page_type.dart";

enum BackgroundProgress { notDownloading, downloading, downloaded }

class LoginPage extends StatefulWidget {
  const LoginPage({required this.loggedIn, super.key, this.setLoggedIn});
  final bool loggedIn;
  final dynamic setLoggedIn;

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  String? userId;
  PageType previousPage = PageType.login;
  PageType currentPage = PageType.login;
  List<String> texts = ["Login"];
  BackgroundProgress backgroundProgress = BackgroundProgress.notDownloading;

  void switchPage(final PageType page, [final String? newUserId]) {
    setState(() {
      currentPage = page;
      userId = newUserId;
    });
  }

  @override
  Widget build(final BuildContext context) {
    commonLogger.d(currentPage.toString());

    if (backgroundProgress == BackgroundProgress.notDownloading) {
      final mediaQuery = MediaQuery.of(context);
      final physicalPixelWidth =
          mediaQuery.size.width * mediaQuery.devicePixelRatio;
      final physicalPixelHeight =
          mediaQuery.size.height * mediaQuery.devicePixelRatio;
      downloadBackgroundImage(physicalPixelWidth, physicalPixelHeight)
          .then((final value) {
        if (value && mounted) {
          setState(() {
            backgroundProgress = BackgroundProgress.downloaded;
          });
        }
      });
      backgroundProgress = BackgroundProgress.downloading;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // BACKGROUND
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage(
                          "assets/backgrounds/graffiti_low_res.png"),
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomLeft,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.4),
                        BlendMode.srcOver,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),

          // FOREGROUND LAYERS
          // Wrap in a scroll view so when keyboard is pulled up it will not cover content
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Stack(
                  children: [
                    Positioned(
                      top: 200,
                      left: 0,
                      child: TextMorphingAnimation(page: currentPage),
                    ),
                    const Positioned(
                        top: 290, right: 0, bottom: 0, child: LayerOne()),
                    const Positioned(
                        top: 318, right: 0, bottom: 28, child: LayerTwo()),
                    LayerThree(
                        loggedIn: widget.loggedIn,
                        setLoggedIn: widget.setLoggedIn,
                        callback: switchPage,
                        page: currentPage,
                        userId: userId),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TextMorphingAnimationState extends State<TextMorphingAnimation> {
  double top = 0; // Initial top position

  // Update the top position based on the page
  void updateAlignment(final PageType page) {
    setState(() {
      switch (page) {
        case PageType.signup:
          top = 200;
        case PageType.forgotPassword:
          top = 300; // Adjust this value as needed
        case PageType.verificationCode:
          top = 400; // Adjust this value as needed
        default:
          top = 200; // Adjust this value as needed
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
  void didUpdateWidget(covariant final TextMorphingAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the alignment when the widget receives a new page
    updateAlignment(widget.page);
  }

  @override
  Widget build(final BuildContext context) => SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AnimatedSwitcher(
            transitionBuilder:
                (final Widget child, final Animation<double> animation) =>
                    FadeTransition(opacity: animation, child: child),
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

  String getTextForPage(final PageType page) {
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
  const TextMorphingAnimation({required this.page, super.key});
  final PageType page;

  @override
  TextMorphingAnimationState createState() => TextMorphingAnimationState();
}
