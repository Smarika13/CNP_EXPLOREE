import 'package:flutter/material.dart';

class EditActivityPage extends StatefulWidget {
  final String name;
  final int domestic;
  final int saarc;
  final int tourist;
  final List<String> timeSlots;

  const EditActivityPage({
    super.key,
    required this.name,
    required this.domestic,
    required this.saarc,
    required this.tourist,
    required this.timeSlots,
  });

  @override
  State<EditActivityPage> createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  late TextEditingController nameController;
  late TextEditingController domesticController;
  late TextEditingController saarcController;
  late TextEditingController touristController;
  late TextEditingController timeslotsController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    domesticController = TextEditingController(text: widget.domestic.toString());
    saarcController = TextEditingController(text: widget.saarc.toString());
    touristController = TextEditingController(text: widget.tourist.toString());
    timeslotsController = TextEditingController(text: widget.timeSlots.join(','));
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Activity"),
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
                    // TODO: Save edited activity
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Activity Updated")),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text("Save Changes", style: TextStyle(fontSize: 16)),
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
        if (value == null || value.isEmpty) return 'Please enter $label';
        return null;
      },
    );
  }
}
