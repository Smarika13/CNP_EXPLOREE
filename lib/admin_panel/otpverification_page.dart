import 'package:flutter/material.dart';

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationPage({super.key, required this.phoneNumber});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final _formKey = GlobalKey<FormState>();

  // 6 controllers for 6 OTP boxes
  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());

  bool isLoading = false;
  bool isResending = false;

  void verifyOTP() {
    if (_formKey.currentState!.validate()) {
      final otp = otpControllers.map((c) => c.text).join();

      if (otp.length != 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter complete OTP")),
        );
        return;
      }

      setState(() => isLoading = true);

      Future.delayed(const Duration(seconds: 2), () {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP verified successfully!")),
        );

        Navigator.pushReplacementNamed(context, '/signupPage2');
      });
    }
  }

  void resendOTP() {
    setState(() => isResending = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isResending = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP resent successfully!")),
      );
    });
  }

  @override
  void dispose() {
    for (final controller in otpControllers) {
      controller.dispose();
    }
    super.dispose();
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
                /// Leaf icon
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
                        "Verify Your Contact",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Enter the OTP sent to ${widget.phoneNumber}",
                        style: const TextStyle(color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // OTP boxes (6 digits)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 45,
                            child: TextFormField(
                              controller: otpControllers[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: const Color(0xFFEFF5EB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  FocusScope.of(context).nextFocus();
                                }
                                if (value.isEmpty && index > 0) {
                                  FocusScope.of(context).previousFocus();
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '';
                                }
                                return null;
                              },
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 20),

                      // Verify OTP Button
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : verifyOTP,
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
                            "Verify OTP",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Resend OTP
                      TextButton(
                        onPressed: isResending ? null : resendOTP,
                        child: isResending
                            ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Text(
                          "Resend OTP",
                          style: TextStyle(
                            color: Color(0xFF4FBF26), // <-- updated green
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Back
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Back",
                          style: TextStyle(
                            color: Color(0xFF4FBF26), // <-- updated green
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
