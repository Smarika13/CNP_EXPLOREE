import 'package:flutter/material.dart';

class CommonLayout extends StatelessWidget {
  final Widget child;

  const CommonLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: const BoxDecoration(
            color: Color(0xFF2E7D32),
          ),
          child: const Text(
            'CMP explore',
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
