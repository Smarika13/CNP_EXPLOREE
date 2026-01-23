import 'package:flutter/material.dart';
import 'shared/common_layout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      child: const Center(
        child: Text('Home Page'),
      ),
    );
  }
}