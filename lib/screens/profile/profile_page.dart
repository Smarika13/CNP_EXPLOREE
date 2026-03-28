import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cnp_navigator/screens/profile/contact_page.dart';
import 'package:cnp_navigator/screens/profile/edit_profile_page.dart';
import 'package:cnp_navigator/screens/profile/faqs_page.dart';
import 'package:cnp_navigator/screens/profile/language_preferences_page.dart';
import 'package:cnp_navigator/screens/profile/logout_page.dart';
import 'package:cnp_navigator/screens/profile/my_account_page.dart';
import 'package:cnp_navigator/screens/profile/my_booking_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> _userData = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (mounted) {
      setState(() {
        _userData = doc.data() ?? {};
        _loading = false;
      });
    }
  }

  String get _fullName   => _userData['fullName']    ?? '';

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
  String get _dob        => _userData['dob']          ?? '';
  String get _age        => _userData['age']?.toString() ?? '';
  String get _gender     => _userData['gender']       ?? '';
  String get _nationality=> _userData['nationality']  ?? '';
  String get _email      => FirebaseAuth.instance.currentUser?.email ?? _userData['email'] ?? '';
  String get _contact    => _userData['contact']      ?? '';

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F6F5),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Greeting banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_greeting${_fullName.isNotEmpty ? ', ${_fullName.split(' ').first}' : ''}! 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _email,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // User Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: ListTile(
                  leading: const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFF1B5E20),
                    child: Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  title: Text(
                    _fullName.isNotEmpty ? _fullName : 'User',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(_email),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  profileOption(Icons.account_circle, "My Account", () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => MyAccountPage(
                        fullName: _fullName, dob: _dob, age: _age,
                        gender: _gender, nationality: _nationality,
                        email: _email, contact: _contact,
                      ),
                    ));
                  }),
                  profileOption(Icons.book_online, "My Booking", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingPage()));
                  }),
                  profileOption(Icons.language, "Language Preferences", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguagePreferencesPage()));
                  }),
                  profileOption(Icons.edit, "Edit Profile", () async {
                    await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => EditProfilePage(
                        fullName: _fullName, dob: _dob, age: _age,
                        gender: _gender, nationality: _nationality,
                        email: _email, contact: _contact,
                      ),
                    ));
                    // Reload after returning from edit
                    _loadUserData();
                  }),
                  profileOption(Icons.help_outline, "FAQs", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const FAQsPage()));
                  }),
                  profileOption(Icons.contact_mail, "Contact Us", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactPage()));
                  }),
                  profileOption(Icons.logout, "Logout", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LogoutPage()));
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileOption(IconData icon, String title, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1B5E20)),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
