import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'screens/profile/my_booking_page.dart';
import 'shared/common_layout.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      child: Column(
        children: [
          // Profile section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: const [
                CircleAvatar(
                  radius: 24,
                  child: Icon(Icons.person, size: 28),
                ),
                SizedBox(width: 16),
                Text(
                  'Sudikshya Tako',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Account options
          Expanded(
            child: ListView(
              children: [
                const _AccountTile(icon: Icons.account_circle, label: 'My Account'),
                _AccountTile(
                  icon: Icons.book_online,
                  label: 'My Bookings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyBookingPage(),
                      ),
                    );
                  },
                ),
                const _AccountTile(icon: Icons.language, label: 'Language Preferences'),
                const _AccountTile(icon: Icons.edit, label: 'Edit Profile'),
                const _AccountTile(icon: Icons.help_outline, label: 'FAQS'),
                const _AccountTile(icon: Icons.contact_mail, label: 'Contact Us'),
                _AccountTile(
                  icon: Icons.logout,
                  label: 'Log Out',
                  onTap: () async {
                    await AuthService().logOut();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _AccountTile({
    required this.icon,
    required this.label,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}