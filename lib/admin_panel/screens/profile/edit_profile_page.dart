import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  final String fullName;
  final String dob;
  final String age;
  final String gender;
  final String nationality;
  final String email;
  final String contact;

  const EditProfilePage({
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
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController fullNameController;
  late TextEditingController dobController;
  late TextEditingController ageController;
  late TextEditingController emailController;
  late TextEditingController contactController;

  String? selectedGender;
  String? selectedNationality;

  final List<String> nationalityOptions = const [
    "Nepalese",
    "Indian",
    "American",
    "British",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.fullName);
    dobController = TextEditingController(text: widget.dob);
    ageController = TextEditingController(text: widget.age);
    emailController = TextEditingController(text: widget.email);
    contactController = TextEditingController(text: widget.contact);
    selectedGender = widget.gender;
    selectedNationality = widget.nationality;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    dobController.dispose();
    ageController.dispose();
    emailController.dispose();
    contactController.dispose();
    super.dispose();
  }

  Future<void> pickDateOfBirth() async {
    DateTime initialDate = DateTime.tryParse(dobController.text) ?? DateTime(2000);

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dobController.text = DateFormat('yyyy-MM-dd').format(picked);

      final today = DateTime.now();
      int age = today.year - picked.year;
      if (today.month < picked.month || (today.month == picked.month && today.day < picked.day)) {
        age--;
      }
      ageController.text = age.toString();
      setState(() {});
    }
  }

  void saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      // Here you can send updated data to backend or state management
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color(0xFF4FBF26),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              // Always show default person icon
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF4FBF26),
                child: Icon(Icons.person, size: 50, color: Colors.black),
              ),
              const SizedBox(height: 16),

              // Full Name
              _textField(fullNameController, "Full Name", 'Please enter your full name'),

              const SizedBox(height: 12),

              // DOB & Age row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: pickDateOfBirth,
                      child: AbsorbPointer(
                        child: _textField(dobController, "Date of Birth", 'Select your date of birth'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: ageController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Age",
                        filled: true,
                        fillColor: const Color(0xFFEFF5EB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Gender
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: _dropdownDecoration("Gender"),
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                  DropdownMenuItem(value: "Other", child: Text("Other")),
                ],
                validator: (value) => value == null ? 'Please select your gender' : null,
                onChanged: (val) => setState(() => selectedGender = val),
              ),

              const SizedBox(height: 12),

              // Nationality
              DropdownButtonFormField<String>(
                value: selectedNationality,
                decoration: _dropdownDecoration("Nationality"),
                items: nationalityOptions
                    .map((nat) => DropdownMenuItem(value: nat, child: Text(nat)))
                    .toList(),
                validator: (value) =>
                value == null ? 'Please select your nationality' : null,
                onChanged: (val) => setState(() => selectedNationality = val),
              ),

              const SizedBox(height: 12),

              // Email
              _textField(emailController, "Email", 'Enter a valid email address', email: true),

              const SizedBox(height: 12),

              // Contact
              _textField(contactController, "Contact No", 'Enter a valid contact number', phone: true),

              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FBF26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xFFEFF5EB),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
  );

  TextFormField _textField(TextEditingController controller, String label, String error,
      {bool email = false, bool phone = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: email
          ? TextInputType.emailAddress
          : phone
          ? TextInputType.phone
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFEFF5EB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return error;
        if (email && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Enter a valid email';
        }
        if (phone && !RegExp(r'^(?:\+977\s\d{10}|\d{10})$').hasMatch(value)) {
          return 'Enter a valid Nepali contact number';
        }
        return null;
      },
    );
  }
}
