import 'package:flutter/material.dart';

class CommonLayout extends StatelessWidget {
  final Widget child;
  final bool showHeader; // Added this variable

  const CommonLayout({
    super.key,
    required this.child,
    this.showHeader = true, // Default to true so other pages still show it
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // This 'if' statement hides or shows the header
        if (showHeader)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF1B5E20),
            ),
            child: const Text(
              'CNP EXPLOREE',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        Expanded(child: child),
      ],
    );
  }
}