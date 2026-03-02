import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. Import Firestore

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController(); // Added Subject
  final TextEditingController _messageController = TextEditingController();
  
  bool _isLoading = false; // To show a loading spinner during upload

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // 2. Updated Submit Function to connect with Firebase
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Sending data to the 'contact_requests' collection
        await FirebaseFirestore.instance.collection('contact_requests').add({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'subject': _subjectController.text.trim(),
          'message': _messageController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(), // For admin sorting
          'status': 'pending', 
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Message sent to Admin successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Clear all fields
          _nameController.clear();
          _emailController.clear();
          _subjectController.clear();
          _messageController.clear();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text("Contact Us", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4FBF26),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Get in Touch",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(_nameController, "Name", Icons.person, (value) {
                    if (value == null || value.isEmpty) return "Please enter your name";
                    return null;
                  }),

                  const SizedBox(height: 16),

                  _buildTextField(_emailController, "Email", Icons.email, (value) {
                    if (value == null || value.isEmpty) return "Please enter your email";
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return "Enter a valid email";
                    return null;
                  }, type: TextInputType.emailAddress),

                  const SizedBox(height: 16),

                  // 3. Added Subject Field
                  _buildTextField(_subjectController, "Subject (e.g. Booking, Issue)", Icons.subject, (value) {
                    if (value == null || value.isEmpty) return "Please enter a subject";
                    return null;
                  }),

                  const SizedBox(height: 16),

                  _buildTextField(_messageController, "Message", Icons.message, (value) {
                    if (value == null || value.isEmpty) return "Please enter your message";
                    if (value.length < 10) return "Minimum 10 characters";
                    return null;
                  }, maxLines: 5),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm, // Disable button while loading
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4FBF26),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Send Message", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to keep code clean
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, String? Function(String?)? validator, {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4FBF26)),
        border: const OutlineInputBorder(),
      ),
      keyboardType: type,
      maxLines: maxLines,
      validator: validator,
    );
  }
}