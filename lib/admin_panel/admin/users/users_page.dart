import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  // Sample users
  final List<Map<String, String>> users = [
    {
      "name": "Sudikshya",
      "email": "sudikshya@example.com",
      "dob": "2000-01-15",
      "age": "26",
      "gender": "Female",
      "nationality": "Nepali",
      "contact": "9841XXXXXX"
    },
    {
      "name": "Ramesh",
      "email": "ramesh@example.com",
      "dob": "1995-07-20",
      "age": "30",
      "gender": "Male",
      "nationality": "Nepali",
      "contact": "9841YYYYYY"
    },
    {
      "name": "Sita",
      "email": "sita@example.com",
      "dob": "1998-03-12",
      "age": "28",
      "gender": "Female",
      "nationality": "Nepali",
      "contact": "9841ZZZZZZ"
    },
  ];

  Map<String, String>? selectedUser; // Holds clicked user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: selectedUser == null ? _buildUserListPage() : _buildUserDetail(),
    );
  }

  /// Users List Page
  Widget _buildUserListPage() {
    return Column(
      children: [
        // ===== Total Users Count =====
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Total Users: ${users.length}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // ===== Users List =====
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedUser = user;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 6)
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: const Color(0xFF4FBF26),
                        child: const Icon(Icons.person,
                            color: Colors.black, size: 25),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        user["name"]!,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// User Detail Page with back arrow
  Widget _buildUserDetail() {
    final user = selectedUser!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ===== Back Arrow =====
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => setState(() => selectedUser = null),
              icon: const Icon(Icons.arrow_back,
                  size: 28, color: Color(0xFF4FBF26)),
            ),
          ),
          const SizedBox(height: 16),
          // ===== User Details Card =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
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
                _infoField("Name", user["name"]!),
                const SizedBox(height: 12),
                _infoField("Email", user["email"]!),
                const SizedBox(height: 12),
                _infoField("Date of Birth", user["dob"]!),
                const SizedBox(height: 12),
                _infoField("Age", user["age"]!),
                const SizedBox(height: 12),
                _infoField("Gender", user["gender"]!),
                const SizedBox(height: 12),
                _infoField("Nationality", user["nationality"]!),
                const SizedBox(height: 12),
                _infoField("Contact", user["contact"]!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable read-only field
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
        const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }
}
