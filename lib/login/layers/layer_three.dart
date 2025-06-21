import "package:flutter/material.dart";
import "package:patinka/login/layers/components/forgot.dart";
import "package:patinka/login/layers/components/login.dart";
import "package:patinka/login/layers/components/signup.dart";
import "package:patinka/login/layers/components/verify.dart";
import "package:patinka/login/page_type.dart";

class LayerThree extends StatelessWidget {
  const LayerThree({
    required this.callback,
    required this.page,
    required this.loggedIn,
    super.key,
    this.setLoggedIn,
  });

  final Function callback;
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
        activeComponent = SignupComponent(callback: callback);
        top = 270;
        break;
      case PageType.forgotPassword:
        activeComponent = ForgotComponent(callback: callback);
        top = 290;
        break;
      case PageType.verificationCode:
        activeComponent = VerifyComponent(callback: callback);
        top = 300;
        break;
      default:
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: top),
          AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            transitionBuilder: (final Widget child, final Animation<double> animation) =>
                SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: const Offset(0.0, 0.05),
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: activeComponent,
          ),
        ],
      ),
    );
  }
}
