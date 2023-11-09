import 'package:flutter/material.dart';
import '../../config.dart';
import '../../page_type.dart';

class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    required this.top,
    required this.label,
    //required this.callback
  });
  final double top;
  final String label;
  //final Function callback;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: top,
        right: MediaQuery.of(context).size.width / 4,
        child: Container(
          width: 199,
          height: 35,
          decoration: BoxDecoration(
            color: signInButton,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: signInText,
                  fontSize: 18,
                  fontFamily: 'Poppins-Medium',
                  fontWeight: FontWeight.w400),
            ),
          ),
        ));
  }
}
