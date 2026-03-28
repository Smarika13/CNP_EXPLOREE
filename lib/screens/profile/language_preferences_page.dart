import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguagePreferencesPage extends StatefulWidget {
  const LanguagePreferencesPage({super.key});

  @override
  State<LanguagePreferencesPage> createState() => _LanguagePreferencesPageState();
}

class _LanguagePreferencesPageState extends State<LanguagePreferencesPage> {
  late String _selectedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLocale = context.locale.languageCode;
  }

  void _save() {
    final locale = Locale(_selectedLocale);
    context.setLocale(locale);
    final langName = _selectedLocale == 'ne' ? 'नेपाली' : 'English';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language set to $langName'),
        backgroundColor: const Color(0xFF4FBF26),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: Text('lang_title'.tr(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B5E20),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'lang_select'.tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildOption('en', 'lang_english'.tr()),
                _buildOption('ne', 'lang_nepali'.tr()),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FBF26),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('save'.tr(),
                        style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(String localeCode, String label) {
    return RadioListTile<String>(
      title: Text(label, style: const TextStyle(fontSize: 16)),
      value: localeCode,
      groupValue: _selectedLocale,
      activeColor: const Color(0xFF4FBF26),
      onChanged: (value) => setState(() => _selectedLocale = value!),
    );
  }
}
