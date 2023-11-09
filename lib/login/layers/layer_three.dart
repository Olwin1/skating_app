import 'package:flutter/material.dart';
import 'package:patinka/login/layers/components/forgot.dart';
import 'package:patinka/login/layers/components/login.dart';
import 'package:patinka/login/layers/components/signup.dart';
import 'package:patinka/login/layers/components/verify.dart';
import '../config.dart';
import '../page_type.dart';

class LayerThree extends StatelessWidget {
  final Function
      callback; // A function to be called when the image has been edited and confirmed.
  final PageType page;

  const LayerThree({super.key, required this.callback, required this.page});

  @override
  Widget build(BuildContext context) {
    Widget activeComponent = LoginComponent(
      callback: callback,
    );
    switch (page) {
      case PageType.signup:
        activeComponent = SignupComponent(
          callback: callback,
        );
        break;
      case PageType.forgotPassword:
        activeComponent = ForgotComponent(
          callback: callback,
        );
        break;
      case PageType.verificationCode:
        activeComponent = VerifyComponent(
          callback: callback,
        );
        break;
      default:
        break;
    }

    return activeComponent;
  }
}
