import "package:flutter/material.dart";
import "package:patinka/login/config.dart";

class PageButton extends StatelessWidget {
  const PageButton(
      {required this.top, required this.label, required this.callback, super.key,
      this.left,
      this.right});
  final double? left;
  final double? right;
  final double top;
  final String label;
  final Function callback;

  @override
  Widget build(final BuildContext context) => Positioned(
        left: left,
        top: top,
        right: right,
        child: TextButton(
            onPressed: callback as VoidCallback,
            child: Text(
              label,
              style: TextStyle(
                  color: forgotPasswordText,
                  fontSize: 16,
                  fontFamily: "Poppins-Medium",
                  fontWeight: FontWeight.w500),
            )));
}
