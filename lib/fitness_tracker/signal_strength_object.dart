import 'package:flutter/material.dart';

class SignalStrengthObject extends StatefulWidget {
  // Create HomePage Class
  const SignalStrengthObject({Key? key})
      : super(key: key); // Take 2 arguments optional key and title of post
  @override
  State<SignalStrengthObject> createState() =>
      _SignalStrengthObject(); //Create state for widget
}

class _SignalStrengthObject extends State<SignalStrengthObject> {
  @override // Override existing build method
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.signal_cellular_0_bar),
        Column(
          children: const [
            Text("Title"),
            Text("bodybodybodybodybodybodybodybodybodybodybody")
          ],
        )
      ],
    );
  }
}
