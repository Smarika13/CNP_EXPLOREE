import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cnp_navigator/screens/profile/contact_page.dart';
import 'package:cnp_navigator/screens/profile/edit_profile_page.dart';
import 'package:cnp_navigator/screens/profile/faqs_page.dart';
import 'package:cnp_navigator/screens/profile/language_preferences_page.dart';
import 'package:cnp_navigator/screens/profile/appearance_page.dart';
import 'package:cnp_navigator/screens/profile/logout_page.dart';
import 'package:cnp_navigator/screens/profile/my_account_page.dart';
import 'package:cnp_navigator/screens/profile/my_booking_page.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current logged-in user's ID
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user logged in.')),
      );
    }

    // This StreamBuilder listens to the 'users' collection in Firestore
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error loading profile')),
          );
        }

        // Pull REAL data from Firestore
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        
        // Use the name from Firebase, fallback to Auth name, then 'User'
        final String fullName    = data['fullName']    ?? user.displayName ?? 'User';
        final String email       = data['email']       ?? user.email ?? '';
        final String dob         = data['dob']         ?? '';
        final String age         = (data['age'] ?? '').toString();
        final String gender      = data['gender']      ?? '';
        final String nationality = data['nationality'] ?? '';
        final String contact     = data['contact']     ?? '';

        return _ProfileBody(
          fullName: fullName,
          email: email,
          dob: dob,
          age: age,
          gender: gender,
          nationality: nationality,
          contact: contact,
        );
      },
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final String fullName;
  final String email;
  final String dob;
  final String age;
  final String gender;
  final String nationality;
  final String contact;

  const _ProfileBody({
    required this.fullName,
    required this.email,
    required this.dob,
    required this.age,
    required this.gender,
    required this.nationality,
    required this.contact,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final firstName = fullName.split(' ').first;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // User Card with greeting
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFF4FBF26),
                        child: Icon(Icons.person, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_greeting, $firstName! 👋',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              email,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Profile Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _profileOption(context, Icons.account_circle, 'profile_my_account'.tr(), () {
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
                  _profileOption(context, Icons.book_online, 'profile_my_booking'.tr(), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyBookingPage()),
                    );
                  }),
                  _profileOption(context, Icons.palette_outlined, 'Appearance', () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const AppearancePage(),
                    ));
                  }),
                  _profileOption(context, Icons.language, 'profile_language'.tr(), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LanguagePreferencesPage()),
                    );
                  }),
                  _profileOption(context, Icons.edit, 'profile_edit'.tr(), () {
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
                  _profileOption(context, Icons.help_outline, 'profile_faqs'.tr(), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FAQsPage()),
                    );
                  }),
                  _profileOption(context, Icons.contact_mail, 'profile_contact'.tr(), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ContactPage()),
                    );
                  }),
                  _profileOption(context, Icons.logout, 'profile_logout'.tr(), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LogoutPage()),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
        ),
      ),
    );
  }

  Widget _profileOption(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
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