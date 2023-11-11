import 'package:flutter/material.dart';
import 'package:patinka/login/layers/components/forgot.dart';
import 'package:patinka/login/layers/components/login.dart';
import 'package:patinka/login/layers/components/signup.dart';
import 'package:patinka/login/layers/components/verify.dart';
import '../page_type.dart';

class LayerThree extends StatelessWidget {
  final Function
      callback; // A function to be called when the image has been edited and confirmed.
  final PageType page;
  final bool loggedIn;
  final dynamic setLoggedIn;

  const LayerThree(
      {super.key,
      required this.callback,
      required this.page,
      required this.loggedIn,
      this.setLoggedIn});

  @override
  Widget build(BuildContext context) {
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
        break;
      case PageType.forgotPassword:
        activeComponent = ForgotComponent(
          callback: callback,
        );
        top = 290;
        break;
      case PageType.verificationCode:
        activeComponent = VerifyComponent(
          callback: callback,
        );
        break;
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
            transitionBuilder: (Widget child, Animation<double> animation) {
              // Use both SlideTransition and FadeTransition
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0), // Slide from the right
                  end: const Offset(0.0, 0.05),
                ).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            duration: const Duration(seconds: 1),
            child: activeComponent,
          ),
        ),
      ],
    );
  }
}
