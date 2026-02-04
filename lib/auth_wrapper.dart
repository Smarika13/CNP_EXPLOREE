import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'home_page.dart';
import 'verify_email_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          // Not logged in
          return const AuthPage();
        }

        // Logged in but email not verified yet -> show verification screen
        if (!user.emailVerified) {
          return const VerifyEmailPage();
        }

        // Logged in and verified
        return const HomePage();
      },
    );
  }
}