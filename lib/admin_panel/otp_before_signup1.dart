import 'package:flutter/material.dart';
import 'otpverification_page.dart';

class OtpBeforeSignup1 extends StatefulWidget {
  const OtpBeforeSignup1({super.key});

  @override
  State<OtpBeforeSignup1> createState() => _OtpBeforeSignup1State();
}

class _OtpBeforeSignup1State extends State<OtpBeforeSignup1> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController contactController = TextEditingController();
  bool isLoading = false;

  void sendOtp() {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      Future.delayed(const Duration(seconds: 2), () {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP would be sent (demo mode)"),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OTPVerificationPage(
              phoneNumber: contactController.text.trim(),
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E2E2E),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// Leaf Icon
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFF4FBF26), // <-- updated green
                  child: Icon(Icons.eco, color: Colors.black, size: 28),
                ),
                const SizedBox(height: 20),

                /// Card
                Container(
                  width: 330,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Enter your phone number or email and we'll send you an OTP to create your account",
                        style: TextStyle(color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      /// Phone or Email Field
                      TextFormField(
                        controller: contactController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Phone Number or Email',
                          hintText: '+977 9800000000 or ram@gmail.com',
                          hintStyle: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFEFF5EB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter phone number or email';
                          }

                          final input = value.trim();

                          final phoneRegex =
                          RegExp(r'^(?:\+977\s?)?\d{10}$');
                          final emailRegex =
                          RegExp(r'^[\w.-]+@gmail\.com$');

                          if (!phoneRegex.hasMatch(input) &&
                              !emailRegex.hasMatch(input)) {
                            return 'Enter valid Nepali phone or Gmail';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      /// Send OTP Button
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4FBF26), // <-- updated green
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.black,
                          )
                              : const Text(
                            "Send OTP",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// Back to Login
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Back to Login",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
