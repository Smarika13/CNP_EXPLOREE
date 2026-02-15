import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SignupPage2 extends StatefulWidget {
  const SignupPage2({super.key});

  @override
  State<SignupPage2> createState() => _SignupPage2State();
}

class _SignupPage2State extends State<SignupPage2> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  String? selectedGender;
  String? selectedNationality;

  final List<String> nationalityOptions = const [
    "Afghan", "Albanian", "Algerian", "American", "Andorran",
    "Angolan", "Argentine", "Armenian", "Australian", "Austrian",
    "Bahamian", "Bangladeshi", "Barbadian", "Belgian", "Bolivian",
    "Brazilian", "British", "Bulgarian", "Cambodian", "Cameroonian",
    "Canadian", "Chilean", "Chinese", "Colombian", "Cuban",
    "Czech", "Danish", "Dutch", "Egyptian", "Ethiopian",
    "Finnish", "French", "German", "Greek", "Honduran",
    "Hungarian", "Icelandic", "Indian", "Indonesian", "Irish",
    "Israeli", "Italian", "Jamaican", "Japanese", "Jordanian",
    "Kenyan", "Korean", "Kuwaiti", "Lebanese", "Malaysian",
    "Mexican", "Moroccan", "Nepalese", "New Zealander", "Norwegian",
    "Pakistani", "Peruvian", "Polish", "Portuguese", "Romanian",
    "Russian", "Saudi", "Scottish", "Serbian", "Singaporean",
    "South African", "Spanish", "Swedish", "Swiss", "Thai",
    "Turkish", "Ukrainian", "Vietnamese", "Zimbabwean",
  ];

  void pickDateOfBirth() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dobController.text = DateFormat('yyyy-MM-dd').format(picked);

      final today = DateTime.now();
      int age = today.year - picked.year;
      if (today.month < picked.month ||
          (today.month == picked.month && today.day < picked.day)) {
        age--;
      }
      ageController.text = age.toString();

      setState(() {});
    }
  }

  void onNextPressed() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All required fields are valid!")),
      );
      // TODO: proceed to next step
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
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        "Signing You Up",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Full Name
                      TextFormField(
                        controller: fullNameController,
                        decoration: InputDecoration(
                          labelText: "Full Name *",
                          filled: true,
                          fillColor: const Color(0xFFEFF5EB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // DOB & Age row
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: pickDateOfBirth,
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: dobController,
                                  decoration: InputDecoration(
                                    labelText: "Date of Birth *",
                                    filled: true,
                                    fillColor: const Color(0xFFEFF5EB),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 18, horizontal: 12),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select your date of birth';
                                    }
                                    int age = int.tryParse(ageController.text) ?? 0;
                                    if (age < 18) {
                                      return 'You must be 18 years or older';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: ageController,
                              readOnly: true,
                              enableInteractiveSelection: false,
                              focusNode: AlwaysDisabledFocusNode(),
                              decoration: InputDecoration(
                                labelText: "Age",
                                filled: true,
                                fillColor: const Color(0xFFEFF5EB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18, horizontal: 12),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Gender Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: selectedGender,
                        decoration: InputDecoration(
                          labelText: "Gender *",
                          filled: true,
                          fillColor: const Color(0xFFEFF5EB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: "Male", child: Text("Male")),
                          DropdownMenuItem(value: "Female", child: Text("Female")),
                          DropdownMenuItem(value: "Other", child: Text("Other")),
                        ],
                        validator: (value) =>
                        value == null ? 'Please select your sex' : null,
                        onChanged: (val) => setState(() {
                          selectedGender = val;
                        }),
                      ),

                      const SizedBox(height: 12),

                      // Nationality Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: selectedNationality,
                        decoration: InputDecoration(
                          labelText: "Nationality *",
                          filled: true,
                          fillColor: const Color(0xFFEFF5EB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 12),
                        ),
                        items: nationalityOptions
                            .map((nat) => DropdownMenuItem(
                          value: nat,
                          child: Text(nat),
                        ))
                            .toList(),
                        validator: (value) =>
                        value == null ? 'Please select your nationality' : null,
                        onChanged: (val) => setState(() {
                          selectedNationality = val;
                        }),
                      ),

                      const SizedBox(height: 12),

                      // Email
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email Address",
                          filled: true,
                          fillColor: const Color(0xFFEFF5EB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 12),
                        ),
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              !RegExp(r'^[\w-\.]+@gmail\.com$').hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Contact Number
                      TextFormField(
                        controller: contactController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Contact No *",
                          filled: true,
                          fillColor: const Color(0xFFEFF5EB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your contact number';
                          }
                          if (!RegExp(r'^(?:\+977\s\d{10}|\d{10})$').hasMatch(value)) {
                            return 'Enter a valid Nepali contact number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      /// Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: onNextPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4FBF26), // <-- updated green
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Sign Up',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom FocusNode to make Age field untouchable
class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
