import "package:flutter/material.dart";
import "package:patinka/login/layers/components/forgot.dart";
import "package:patinka/login/layers/components/login.dart";
import "package:patinka/login/layers/components/signup.dart";
import "package:patinka/login/layers/components/verify.dart";
import "package:patinka/login/page_type.dart";

class LayerThree extends StatelessWidget {
  const LayerThree(
      {required this.callback,
      required this.page,
      required this.loggedIn,
      super.key,
      this.setLoggedIn});
  final Function
      callback; // A function to be called when the image has been edited and confirmed.
  final PageType page;
  final bool loggedIn;
  final dynamic setLoggedIn;

  @override
  Widget build(final BuildContext context) {
    Widget activeComponent = LoginComponent(
      callback: callback,
      loggedIn: loggedIn,
      setLoggedIn: setLoggedIn,
    );
    double top = 320;
    switch (page) {
      case PageType.signup:
        activeComponent = SignupComponent(
          callback: callback,
        );
        top = 270;
      case PageType.forgotPassword:
        activeComponent = ForgotComponent(
          callback: callback,
        );
        top = 290;
      case PageType.verificationCode:
        activeComponent = VerifyComponent(
          callback: callback,
        );
      default:
        break;
    }

    return Stack(
      children: [
        Positioned(
          top: top,
          right: 0,
          bottom: 48,
          child: AnimatedSwitcher(
            transitionBuilder:
                (final Widget child, final Animation<double> animation) =>
                    SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0), // Slide from the right
                end: const Offset(0.0, 0.05),
              ).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            ),
            duration: const Duration(seconds: 1),
            child: activeComponent,
          ),
        ),
      ],
    );
  }
}
