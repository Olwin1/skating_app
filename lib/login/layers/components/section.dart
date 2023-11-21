import 'package:flutter/material.dart';
import 'package:patinka/swatch.dart';
import '../../config.dart';

class InputSection extends StatelessWidget {
  const InputSection(
      {super.key,
      this.left,
      this.right,
      required this.top,
      required this.label,
      required this.hint,
      required this.controller,
      this.hidden});
  final double? left;
  final double? right;
  final double top;
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool? hidden;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        left: left,
        top: top,
        child: Text(
          label,
          style: TextStyle(
              fontFamily: 'Poppins-Medium',
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: labelColour),
        ),
      ),
      Positioned(
          left: left,
          right: right,
          top: top + 30,
          child: SizedBox(
            width: 310,
            child: TextField(
                cursorColor: swatch[801],
                controller: controller,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: swatch[100]!)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: swatch[501]!)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: swatch[100]!, width: 1.5)),
                  hintText: hint,
                  hintStyle: TextStyle(color: hintText),
                ),
                style: TextStyle(color: swatch[901]),
                obscureText: hidden ?? false),
          )),
    ]);
  }
}
