import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_screen.dart';
import 'home_page.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _isSending = false;
  bool _isChecking = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  static final _actionCodeSettings = ActionCodeSettings(
    url: 'https://cnpp-58096.firebaseapp.com/verify',
    handleCodeInApp: false,
    androidPackageName: 'com.example.cnp_app',
    androidInstallApp: true,
    androidMinimumVersion: '1',
  );

  Future<void> _resendEmail() async {
    if (_user == null) return;
    setState(() => _isSending = true);
    try {
      await _user!.sendEmailVerification(_actionCodeSettings);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent. Check your inbox and spam folder.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _checkVerified() async {
    if (_user == null) return;
    setState(() => _isChecking = true);
    await _user!.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;
    if (!mounted) return;
    setState(() => _isChecking = false);

    if (refreshedUser != null && refreshedUser.emailVerified) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Still not verified. Please click the link in your email.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final navigator = Navigator.of(context);
            await FirebaseAuth.instance.signOut();
            if (!mounted) return;
            navigator.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const AuthPage(initialIsLogin: false),
              ),
              (route) => false,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'A verification link has been sent to:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please check your email and click the verification link, '
              'then come back and tap "I have verified".',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber.shade700, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Can't find it? Check your Spam or Junk folder. "
                      "Mark the email as 'Not Spam' so future emails reach your inbox.",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSending ? null : _resendEmail,
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Resend Verification Email'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isChecking ? null : _checkVerified,
              child: _isChecking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('I have verified'),
            ),
          ],
        ),
      ),
    );
  }
}

