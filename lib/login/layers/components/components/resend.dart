import "dart:async";
import "package:flutter/material.dart";
import "package:patinka/api/auth.dart";

class CountdownButton extends StatefulWidget {
  const CountdownButton({required this.userId, super.key});

  final String userId;

  @override
  State<CountdownButton> createState() => _CountdownButtonState();
}

class _CountdownButtonState extends State<CountdownButton> {
  bool isCountingDown = false;
  int remainingSeconds = 0;
  Timer? timer;

  void startCountdown() {
    setState(() {
      isCountingDown = true;
      remainingSeconds = 60; // countdown from 60
    });

    timer = Timer.periodic(const Duration(seconds: 1), (final t) {
      if (remainingSeconds == 1) {
        t.cancel();
        setState(() {
          isCountingDown = false;
        });
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => TextButton(
        onPressed: () => {
          if (!isCountingDown)
            {startCountdown(), AuthenticationAPI.resendEmail(widget.userId)}
        },
        child: Text(
          isCountingDown ? "Resend: $remainingSeconds" : "Resend",
        ),
      );
}
