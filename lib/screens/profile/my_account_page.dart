import 'package:flutter/material.dart';

class MyAccountPage extends StatelessWidget {
  final String fullName;
  final String dob;
  final String age;
  final String gender;
  final String nationality;
  final String email;
  final String contact;

  const MyAccountPage({
    super.key,
    required this.fullName,
    required this.dob,
    required this.age,
    required this.gender,
    required this.nationality,
    required this.email,
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text("My Account"),
        backgroundColor: const Color(0xFF1B5E20),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // User Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFF4FBF26),
                      child: Icon(Icons.person, color: Colors.black, size: 40),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _infoField("Full Name", fullName),
                  const SizedBox(height: 12),
                  _infoField("Date of Birth", dob),
                  const SizedBox(height: 12),
                  _infoField("Age", age),
                  const SizedBox(height: 12),
                  _infoField("Gender", gender),
                  const SizedBox(height: 12),
                  _infoField("Nationality", nationality),
                  const SizedBox(height: 12),
                  _infoField("Email", email),
                  const SizedBox(height: 12),
                  _infoField("Contact No", contact),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable read-only field widget
  Widget _infoField(String label, String value) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFEFF5EB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      ),
    );
  }
}
