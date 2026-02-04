import 'package:flutter/material.dart';

import 'shared/common_layout.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonLayout(
      child: Center(
        child: Text(
          'Welcome! You are logged in.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

