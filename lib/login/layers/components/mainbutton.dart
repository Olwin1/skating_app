import "package:flutter/material.dart";
import "package:patinka/login/config.dart";

class MainButton extends StatelessWidget {
  const MainButton(
      {required this.top, required this.label, required this.callback, super.key});
  final double top;
  final String label;
  final Function callback;

  @override
  Widget build(final BuildContext context) => Positioned(
        top: top,
        right: MediaQuery.of(context).size.width / 4,
        child: InkWell(
          onTap: callback as GestureTapCallback,
          child: Container(
            width: 199,
            height: 35,
            decoration: BoxDecoration(
              color: signInButton,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: signInText,
                  fontSize: 18,
                  fontFamily: "Poppins-Medium",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ));
}
