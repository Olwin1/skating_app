import 'package:flutter/material.dart';
import '../../config.dart';

class PageButton extends StatelessWidget {
  const PageButton(
      {super.key,
      this.left,
      this.right,
      required this.top,
      required this.label,
      required this.callback});
  final double? left;
  final double? right;
  final double top;
  final String label;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: left,
        top: top,
        right: right,
        child: TextButton(
            onPressed: () => callback(),
            child: Text(
              label,
              style: TextStyle(
                  color: forgotPasswordText,
                  fontSize: 16,
                  fontFamily: 'Poppins-Medium',
                  fontWeight: FontWeight.w500),
            )));
  }
}
