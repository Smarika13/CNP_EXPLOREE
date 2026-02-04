import 'package:flutter/material.dart';
import 'package:activity_booking_system/screens/profile/logout_page.dart';
import 'package:activity_booking_system/screens/profile/my_account_page.dart';
import 'package:activity_booking_system/screens/profile/my_booking_page.dart';
import 'package:activity_booking_system/screens/profile/language_preferences_page.dart';
import 'package:activity_booking_system/screens/profile/edit_profile_page.dart';
import 'package:activity_booking_system/screens/profile/faqs_page.dart';
import 'package:activity_booking_system/screens/profile/contact_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Dummy user data - replace with real data from backend or state management
  final String fullName = "Sudikshya";
  final String dob = "2000-01-01";
  final String age = "26";
  final String gender = "Female";
  final String nationality = "Nepalese";
  final String email = "sudikshya@example.com";
  final String contact = "+9779800000000";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),

      // AppBar removed

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // User Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  leading: const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFF4FBF26),
                    child: Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  title: Text(
                    fullName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(email),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Profile options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  profileOption(Icons.account_circle, "My Account", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyAccountPage(
                          fullName: fullName,
                          dob: dob,
                          age: age,
                          gender: gender,
                          nationality: nationality,
                          email: email,
                          contact: contact,
                        ),
                      ),
                    );
                  }),
                  profileOption(Icons.book_online, "My Booking", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyBookingPage()),
                    );
                  }),
                  profileOption(Icons.language, "Language Preferences", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LanguagePreferencesPage()),
                    );
                  }),
                  profileOption(Icons.edit, "Edit Profile", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfilePage(
                          fullName: fullName,
                          dob: dob,
                          age: age,
                          gender: gender,
                          nationality: nationality,
                          email: email,
                          contact: contact,
                        ),
                      ),
                    );
                  }),
                  profileOption(Icons.help_outline, "FAQs", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FAQsPage()),
                    );
                  }),
                  profileOption(Icons.contact_mail, "Contact Us", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ContactPage()),
                    );
                  }),
                  profileOption(Icons.logout, "Logout", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LogoutPage()),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable profile option row
  Widget profileOption(IconData icon, String title, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4FBF26)),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
