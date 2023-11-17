import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_template/flutter_login_template.dart';
import 'package:patinka/api/auth.dart'; // signup;
import 'package:patinka/api/social.dart';
import 'package:patinka/api/token.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:patinka/common_logger.dart';

// Define an enum to represent different states of the login screen
enum _State {
  signIn,
  signUp,
  forgot,
  confirm,
  create,
}

SecureStorage storage = SecureStorage();

// Create a StatefulWidget for the login screen
class Login extends StatefulWidget {
  // Take two arguments: a key and the title of the page
  const Login({super.key, required this.loggedIn, this.setLoggedIn});
  final bool loggedIn;
  final dynamic setLoggedIn;

  @override
  State<Login> createState() =>
      _Login(); // Create a state object for the widget
}

// Define the state object for the login screen
class _Login extends State<Login> {
  // Define some styles to customize the appearance of the login template
  static const color = Colors.transparent;
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
// Create controllers for the username and password input fields
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  var usernameSignupController = TextEditingController();
  var emailSignupController = TextEditingController();
  var passwordSignupController = TextEditingController();
  var passwordConfirmSignupController = TextEditingController();
// Set a variable for error text that will be displayed if there is an error during sign-in
  String errorText = "";

// The build method is called to build the UI of the widget
  @override
  Widget build(BuildContext context) {
    // Define a function to load the home screen when sign-in is successful
    void loadHome() {
      widget.setLoggedIn(true);
    }

    // Create an icon for the logo of the login screen
    const logo = Icon(
      Icons.android_rounded,
      size: 80,
    );
    // Define the sign-in page of the login template with the input fields and sign-in button
    var signInPage = LoginTemplateSignInPage(
      logo: logo,
      style: style,
      controllerUser: usernameController,
      controllerPassword: passwordController,
      hintTextUser: AppLocalizations.of(context)!.username,
      hintTextPassword: AppLocalizations.of(context)!.password,
      buttonTextForgotPassword: AppLocalizations.of(context)!.forgotPassword,
      buttonTextSignIn: AppLocalizations.of(context)!.signIn,
      errorTextPassword: errorText,
      onPressedSignIn: () async {
        // When the user taps the sign-in button, try to log them in
        try {
          // Call the login function with the username and password provided
          var res =
              await login(usernameController.text, passwordController.text);
          // If login is successful, save the user's token to local storage
          await storage.setToken(res);
          SocialAPI.getUser("0")
              .then((value) => storage.setId(value["user_id"]));
          // Load the home screen
          loadHome();
          commonLogger.d("Result: $res");
        } catch (e) {
          mounted
              ? setState(() {
                  errorText = "Your username or password is incorrect";
                })
              : null;
          commonLogger.e("An error has occured: $e");
        }
      },
      onPressedSignUp: () {
        mounted
            ? setState(() {
                state = _State.signUp;
              })
            : null;
      },
      onPressedForgot: () {
        mounted
            ? setState(() {
                state = _State.forgot;
              })
            : null;
      },
      /* term: LoginTemplateTerm(
        style: style,
        onPressedTermOfService: () {},
        onPressedPrivacyPolicy: () {},
      ),*/
    );

// Define a variable for the SignUp page with logo, style, and buttons.
    var signUpPage = LoginTemplateSignUpPage(
      controllerFullName: usernameSignupController,
      controllerUser: emailSignupController,
      hintTextFullName: "Username",
      hintTextUser: "Email",
      logo: logo,
      style: style,
      onPressedSignIn: () {
        // When the user taps the "Sign In" button, set the state to signIn.
        mounted
            ? setState(() {
                state = _State.signIn;
              })
            : null;
      },
      onPressedSignUp: () {
        if (EmailValidator.validate(emailSignupController.text)) {
          if (usernameSignupController.text.length > 3 &&
              usernameSignupController.text.length < 29) {
            // When the user taps the "Sign Up" button, set the state to confirm.
            mounted
                ? setState(() {
                    state = _State.create;
                  })
                : null;
          } else {
            commonLogger.i("Username is too short");
          }
        } else {
          commonLogger.i("Email format is incorrect");
        }
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
          mounted
              ? setState(() {
                  state = _State.confirm;
                })
              : null;
        });

// Define a variable for the Confirm Code page with logo, style, and buttons.
    var confirmCodePage = LoginTemplateConfirmCodePage(
      logo: logo,
      style: style,
      onPressedNext: () {
        // When the user taps the "Next" button, set the state to create.
        mounted
            ? setState(() {
                state = _State.create;
              })
            : null;
      },
      onPressedResend: () {},
    );

// Define a variable for the Create Password page with logo, style, and button.
    var createPassword = LoginTemplateCreatePasswordPage(
      controllerPassword: passwordSignupController,
      controllerConfirmPassword: passwordConfirmSignupController,
      logo: logo,
      style: style,
      errorTextPassword: 'The password you entered is incorrect.',
      onPressedNext: () {
        if (passwordSignupController.text ==
            passwordConfirmSignupController.text) {
          if (passwordSignupController.text.length >= 6) {
            signup(usernameSignupController.text, passwordSignupController.text,
                    emailSignupController.text)
                .then((value) => {
                      mounted
                          ? setState(() {
                              state = _State.signIn;
                            })
                          : null
                    });
            // When the user taps the "Next" button, set the state to signIn.
          }
        }
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
    void check() => {
          if (state != _State.signIn)
            {
              mounted
                  ? setState(() {
                      state = _State.signIn;
                    })
                  : null
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
        text = AppLocalizations.of(context)!.signIn;
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
        child: Stack(children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image:
                          const AssetImage("assets/backgrounds/graffiti.png"),
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomLeft,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.5), BlendMode.srcOver)),
                ),
                padding: const EdgeInsets.all(16)),
          ),
          body
        ]),
      ),
    );
  }
}
