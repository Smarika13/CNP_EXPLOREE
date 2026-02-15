import 'package:flutter/material.dart';

class AddActivityPage extends StatefulWidget {
  const AddActivityPage({super.key});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController domesticController = TextEditingController();
  final TextEditingController saarcController = TextEditingController();
  final TextEditingController touristController = TextEditingController();
  final TextEditingController timeslotsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Activity"),
        backgroundColor: const Color(0xFF4FBF26),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Activity Name", nameController),
              const SizedBox(height: 16),
              _buildTextField("Domestic Price (Rs.)", domesticController, isNumber: true),
              const SizedBox(height: 16),
              _buildTextField("SAARC Price (Rs.)", saarcController, isNumber: true),
              const SizedBox(height: 16),
              _buildTextField("Other Tourists Price (Rs.)", touristController, isNumber: true),
              const SizedBox(height: 16),
              _buildTextField(
                "Time Slots (comma separated, e.g., 6–10 AM,2–5 PM)",
                timeslotsController,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FBF26),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: Save activity to database or list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Activity Added")),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text("Add Activity", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
