import 'package:cnp_navigator/admin_panel/admin/admin_page.dart';
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

        // 1. If not logged in, show the Login screen
        if (user == null) {
          return const AuthPage();
        }

        final email = user.email ?? "";
        final isAdmin = email == 'chitwan@admin.cnp' || email.endsWith('.admin.cnp');

        // 2. ADMIN BYPASS
        // Now returns the actual dashboard instead of just text
        if (isAdmin) {
          return const AdminPage(); 
        }

        // 3. CHECK CUSTOMER VERIFICATION
        if (!user.emailVerified) {
          return const VerifyEmailPage();
        }

        // 4. Verified Customer
        return const HomePage();
      },
    );
  }
}