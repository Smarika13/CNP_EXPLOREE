import 'package:flutter/material.dart';
import '../../auth_service.dart'; // [cite: 504]

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text("Logout"),
        backgroundColor: const Color(0xFF1B5E20),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.logout,
                  color: Color(0xFF4FBF26),
                  size: 60,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Do you want to logout?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- YES BUTTON ---
                    ElevatedButton(
                      onPressed: () async {
                        // 1. Call the logout logic from your AuthService 
                        await AuthService().logOut();

                        // 2. Clear all previous routes and go to the root ('/')
                        // This triggers AuthWrapper to show the AuthPage (Login) 
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/', 
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Yes"),
                    ),
                    const SizedBox(width: 16),
                    // --- NO BUTTON ---
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Simply closes the logout screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("No"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}