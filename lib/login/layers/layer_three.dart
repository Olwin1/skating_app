import 'package:flutter/material.dart';
import '../config.dart';
import '../page_type.dart';

class LayerThree extends StatefulWidget {
  final Function
      callback; // A function to be called when the image has been edited and confirmed.

  // Constructor for the EditPost widget.
  const LayerThree(
      {Key? key, // A key to identify this widget.
      required this.callback})
      : super(key: key);

  @override
  State<LayerThree> createState() => _LayerThree();
}

class _LayerThree extends State<LayerThree> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 584,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 59,
            top: 99,
            child: Text(
              'Username',
              style: TextStyle(
                  fontFamily: 'Poppins-Medium',
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: labelColour),
            ),
          ),
          Positioned(
              left: 59,
              top: 129,
              child: SizedBox(
                width: 310,
                child: TextField(
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    hintText: 'Enter User ID or Email',
                    hintStyle: TextStyle(color: hintText),
                  ),
                ),
              )),
          Positioned(
            left: 59,
            top: 199,
            child: Text(
              'Password',
              style: TextStyle(
                  fontFamily: 'Poppins-Medium',
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: labelColour),
            ),
          ),
          Positioned(
              left: 59,
              top: 229,
              child: SizedBox(
                width: 310,
                child: TextField(
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    hintText: 'Enter Password',
                    hintStyle: TextStyle(color: hintText),
                  ),
                ),
              )),
          Positioned(
            right: 60,
            top: 296,
            child: TextButton(
                onPressed: () => widget.callback(PageType.forgotPassword),
                child: Text(
                  'Forgot Password',
                  style: TextStyle(
                      color: forgotPasswordText,
                      fontSize: 16,
                      fontFamily: 'Poppins-Medium',
                      fontWeight: FontWeight.w600),
                )),
          ),
          Positioned(
              left: 87,
              top: 296,
              child: TextButton(
                  onPressed: () => widget.callback(PageType.signup),
                  child: Text(
                    'Signup',
                    style: TextStyle(
                        color: forgotPasswordText,
                        fontSize: 16,
                        fontFamily: 'Poppins-Medium',
                        fontWeight: FontWeight.w500),
                  ))),
          Positioned(
              top: 365,
              right: MediaQuery.of(context).size.width / 4,
              child: Container(
                width: 199,
                height: 35,
                decoration: BoxDecoration(
                  color: signInButton,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    'Sign In',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: signInText,
                        fontSize: 18,
                        fontFamily: 'Poppins-Medium',
                        fontWeight: FontWeight.w400),
                  ),
                ),
              )),
          Positioned(
              top: 432,
              left: 59,
              child: Container(
                height: 0.5,
                width: 310,
                color: inputBorder,
              )),
          Positioned(
              top: 482,
              left: 120,
              right: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 59,
                    height: 48,
                    decoration: BoxDecoration(
                        border: Border.all(color: signInBox),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20))),
                    child: Image.asset(
                      'images/icon_google.png',
                      width: 20,
                      height: 21,
                    ),
                  ),
                  Text(
                    'or',
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins-Regular',
                        color: hintText),
                  ),
                  Container(
                    width: 59,
                    height: 48,
                    decoration: BoxDecoration(
                        border: Border.all(color: signInBox),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20))),
                    child: Image.asset(
                      'images/icon_apple.png',
                      width: 20,
                      height: 21,
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
