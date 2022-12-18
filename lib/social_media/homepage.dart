import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  // Create HomePage Class
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title; // Define title argument
  @override // Override the existing widget build method
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const Center(
        child: Text("Social Media Page"), // Add Placeholder text
      ),
    );
  }
}
