import 'package:cnp_navigator/screens/profile/contact_page.dart';
import 'package:cnp_navigator/screens/profile/faqs_page.dart';
import 'package:cnp_navigator/screens/profile/language_preferences_page.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'screens/profile/my_booking_page.dart';
import 'shared/common_layout.dart';

// Enum to manage the different views within the Profile Page
enum ProfileView { menu, contact, language, faq }

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Default view is the menu
  ProfileView _currentView = ProfileView.menu;

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 800;

          return Column(
            children: [
              // --- SHARED PROFILE HEADER ---
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: isWide ? constraints.maxWidth * 0.1 : 16,
                ),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: isWide ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    // Back button appears when not on the main menu
                    if (_currentView != ProfileView.menu)
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF4FBF26)),
                        onPressed: () {
                          setState(() => _currentView = ProfileView.menu);
                        },
                      ),
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFF4FBF26),
                      child: Icon(Icons.person, size: 32, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Sudikshya Tako',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // --- DYNAMIC CONTENT AREA ---
              Expanded(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 800 : double.infinity,
                    ),
                    child: _buildCurrentContent(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Switches the view based on state
  Widget _buildCurrentContent() {
    switch (_currentView) {
      case ProfileView.contact:
        return const ContactPage();
      case ProfileView.language:
        return const LanguagePreferencesPage();
      case ProfileView.faq:
        return const FAQsPage();
      case ProfileView.menu:
      default:
        return _buildMenu();
    }
  }

  Widget _buildMenu() {
    return ListView(
      children: [
        const _AccountTile(icon: Icons.account_circle, label: 'My Account'),
        _AccountTile(
          icon: Icons.book_online,
          label: 'My Bookings',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyBookingPage()),
            );
          },
        ),
        _AccountTile(
          icon: Icons.language,
          label: 'Language Preferences',
          onTap: () => setState(() => _currentView = ProfileView.language),
        ),
        const _AccountTile(icon: Icons.edit, label: 'Edit Profile'),
        _AccountTile(
          icon: Icons.help_outline,
          label: 'FAQS',
          onTap: () => setState(() => _currentView = ProfileView.faq),
        ),
        _AccountTile(
          icon: Icons.contact_mail,
          label: 'Contact Us',
          onTap: () => setState(() => _currentView = ProfileView.contact),
        ),
        _AccountTile(
          icon: Icons.logout,
          label: 'Log Out',
          onTap: () async {
            await AuthService().logOut();
          },
        ),
      ],
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _AccountTile({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4FBF26)),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}