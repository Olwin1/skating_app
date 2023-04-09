import 'package:flutter/material.dart';
import 'package:flutter_login_template/flutter_login_template.dart';

// Define an enum to represent different states of the login screen
enum _State {
  signIn,
  signUp,
  forgot,
  confirm,
  create,
}

// Create a StatefulWidget for the login screen
class Login extends StatefulWidget {
  // Take two arguments: a key and the title of the page
  const Login({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<Login> createState() =>
      _Login(); // Create a state object for the widget
}

// Define the state object for the login screen
class _Login extends State<Login> {
  // Define some styles to customize the appearance of the login template
  static const color = Colors.black;
  LoginTemplateStyle style = LoginTemplateStyle(
    textFieldHintTextStyle: const TextStyle(),
    textFieldErrorTextStyle: const TextStyle(),
    socialButtonStyle: ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    screenPadding: const EdgeInsets.all(32),
    verticalSpacingBetweenComponents: 16,
    verticalSpacingBetweenSubComponents: 8,
    verticalSpacingBetweenGroup: 8,
    inlineButtonTextStyle:
        const TextStyle(color: Color.fromARGB(255, 71, 78, 183)),
    messageTextStyle: const TextStyle(),
    socialButtonTextStyle: const TextStyle(),
    itemShadow: const BoxShadow(
      color: Color.fromARGB(62, 0, 0, 0),
      offset: Offset(5, 10),
      blurRadius: 4.0,
      blurStyle: BlurStyle.normal,
      spreadRadius: 0.1,
    ),
    textFieldTextStyle: const TextStyle(),
    inlineButtonStyle: ButtonStyle(
      shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
      backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    primary: color,
    primaryDark: color,
    primaryLight: color,
    buttonOverlay: color,
    buttonStyle: ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    textFieldPadding: const EdgeInsets.all(8),
    buttonTextStyle: const TextStyle(),
  );

  // Keep track of the current state of the login screen
  _State state = _State.signIn;

  @override
  Widget build(BuildContext context) {
    // Create an icon for the logo of the login screen
    const logo = Icon(
      Icons.android_rounded,
      size: 80,
    );

    // Define the sign-in page of the login template
    var signInPage = LoginTemplateSignInPage(
      logo: logo,
      style: style,
      hintTextUser: "Username",
      onPressedSignIn: () {},
      onPressedSignUp: () {
        setState(() {
          state = _State.signUp;
        });
      },
      onPressedForgot: () {
        setState(() {
          state = _State.forgot;
        });
      },
      /* term: LoginTemplateTerm(
        style: style,
        onPressedTermOfService: () {},
        onPressedPrivacyPolicy: () {},
      ),*/
    );

// Define a variable for the SignUp page with logo, style, and buttons.
    var signUpPage = LoginTemplateSignUpPage(
      logo: logo,
      style: style,
      onPressedSignIn: () {
        // When the user taps the "Sign In" button, set the state to signIn.
        setState(() {
          state = _State.signIn;
        });
      },
      onPressedSignUp: () {
        // When the user taps the "Sign Up" button, set the state to confirm.
        setState(() {
          state = _State.confirm;
        });
      },
      // Define a widget for the terms of service and privacy policy.
      term: LoginTemplateTerm(
        style: style,
        onPressedTermOfService: () {},
        onPressedPrivacyPolicy: () {},
      ),
    );

// Define a variable for the Forgot Password page with logo, style, and button.
    var forgotPasswordPage = LoginTemplateForgotPasswordPage(
        logo: logo,
        style: style,
        onPressedNext: () {
          // When the user taps the "Next" button, set the state to confirm.
          setState(() {
            state = _State.confirm;
          });
        });

// Define a variable for the Confirm Code page with logo, style, and buttons.
    var confirmCodePage = LoginTemplateConfirmCodePage(
      logo: logo,
      style: style,
      onPressedNext: () {
        // When the user taps the "Next" button, set the state to create.
        setState(() {
          state = _State.create;
        });
      },
      onPressedResend: () {},
    );

// Define a variable for the Create Password page with logo, style, and button.
    var createPassword = LoginTemplateCreatePasswordPage(
      logo: logo,
      style: style,
      errorTextPassword: 'The password you entered is incorrect.',
      onPressedNext: () {
        // When the user taps the "Next" button, set the state to signIn.
        setState(() {
          state = _State.signIn;
        });
      },
    );

// Define a variable for the current page based on the current state.
    Widget body;
    switch (state) {
      case _State.signUp:
        body = signUpPage;
        break;
      case _State.forgot:
        body = forgotPasswordPage;
        break;
      case _State.confirm:
        body = confirmCodePage;
        break;
      case _State.create:
        body = createPassword;
        break;
      case _State.signIn:
      default:
        body = signInPage;
        break;
    }

// Define a function to check if the state is not signIn and set it to signIn if needed.
    check() => {
          if (state != _State.signIn)
            {
              setState(() {
                state = _State.signIn;
              })
            }
        };

// Define a variable for the text to display in the app bar based on the current state.
    String text;
    switch (state) {
      case _State.signUp:
        text = "Sign Up";
        break;
      case _State.forgot:
      case _State.confirm:
      case _State.create:
        text = "Reset Password";
        break;
      case _State.signIn:
      default:
        text = "Sign In";
        break;
    }

// Return the app scaffold with the app bar and current page.
    return Scaffold(
      appBar: AppBar(
        title: Text(text),
        leading: state == _State.signIn
            ? null
            : BackButton(
                onPressed: () => {check()},
              ),
      ),
      body: SingleChildScrollView(
        child: body,
      ),
    );
  }
}
