import 'package:flutter/material.dart';

import 'profile_page.dart';

/// Thin wrapper kept for any old references.
/// Always shows the real profile UI instead of a placeholder.
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfilePage();
  }
}
