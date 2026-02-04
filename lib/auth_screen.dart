import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'reset_password.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLogin = true; // State to toggle between Login and Sign Up
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final service = AuthService();

    setState(() => _isLoading = true);

    String? error;

    if (_isLogin) {
      error = await service.logIn(email, password);
    } else {
      error = await service.signUp(email, password);

      // Send verification email on successful sign up
      if (error == null) {
        try {
          final user = FirebaseAuth.instance.currentUser;
          await user?.sendEmailVerification();
        } catch (_) {
          // Ignore verification errors in UI flow
        }
      }
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLogin
                ? 'Login successful'
                : 'Sign up successful. Check your email for a verification link.',
          ),
        ),
      );
      // AuthWrapper listens to authStateChanges and will route to HomePage automatically.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E2E2E), // Dark background from original
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Leaf Logo
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFF7CFF4E),
                child: Icon(Icons.eco, color: Colors.black, size: 28),
              ),
              const SizedBox(height: 20),

              // White Card Container
              Container(
                width: 330,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        _isLogin ? "CNP EXPLOREE" : "CREATE ACCOUNT",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: ' Email',
                          hintText: 'name@gmail.com',
                          prefixIcon: const Icon(Icons.email),
                          filled: true,
                          fillColor: const Color(0xFFEFF5EB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter email';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFEFF5EB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter password';
                          if (value.length < 6) return 'Minimum 6 characters';
                          return null;
                        },
                      ),

                      // Forgot Password (only visible in Login mode)
                      if (_isLogin)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
                              );
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.green, decoration: TextDecoration.underline),
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),

                      // Main Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7CFF4E),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                )
                              : Text(
                                  _isLogin ? 'Login' : 'Sign Up',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Toggle between Login and Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_isLogin ? "Don’t have an account? " : "Already have an account? "),
                          GestureDetector(
                            onTap: () => setState(() => _isLogin = !_isLogin),
                            child: Text(
                              _isLogin ? "Sign Up" : "Login",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}