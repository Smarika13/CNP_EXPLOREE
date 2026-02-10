import 'package:flutter/material.dart';

class LanguagePreferencesPage extends StatefulWidget {
  const LanguagePreferencesPage({super.key});

  @override
  State<LanguagePreferencesPage> createState() => _LanguagePreferencesPageState();
}

class _LanguagePreferencesPageState extends State<LanguagePreferencesPage> {
  String _selectedLanguage = "English";

  @override
  Widget build(BuildContext context) {
    // Removed Scaffold and AppBar
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Constrain size
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Language",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildLanguageOption("English"),
              _buildLanguageOption("Nepali"),
              _buildLanguageOption("Hindi"),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Language set to $_selectedLanguage"),
                        backgroundColor: const Color(0xFF4FBF26),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FBF26),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Save", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String lang) {
    return RadioListTile<String>(
      title: Text(lang),
      value: lang,
      groupValue: _selectedLanguage,
      activeColor: const Color(0xFF4FBF26),
      onChanged: (value) {
        setState(() => _selectedLanguage = value!);
      },
    );
  }
}