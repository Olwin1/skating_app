import 'package:flutter/material.dart';
import '../../config.dart';
import '../../page_type.dart';

class InputSection extends StatelessWidget {
  const InputSection(
      {super.key,
      this.left,
      this.right,
      required this.top,
      required this.label,
      required this.hint,
      required this.controller});
  final double? left;
  final double? right;
  final double top;
  final String label;
  final String hint;
  final TextEditingController controller;

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
              controller: controller,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText: hint,
                hintStyle: TextStyle(color: hintText),
              ),
            ),
          )),
    ]);
  }
}
