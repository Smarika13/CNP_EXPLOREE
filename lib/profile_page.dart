import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Account tab selected
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notices'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            color: Colors.green,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(
                  children: [
                    Icon(Icons.eco, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'CNP EXPLOREE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.more_vert, color: Colors.white),
              ],
            ),
          ),

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
              children: const [
                AccountTile(icon: Icons.account_circle, label: 'My Account'),
                AccountTile(icon: Icons.book_online, label: 'My Bookings'),
                AccountTile(icon: Icons.language, label: 'Language Preferences'),
                AccountTile(icon: Icons.edit, label: 'Edit Profile'),
                AccountTile(icon: Icons.help_outline, label: 'FAQS'),
                AccountTile(icon: Icons.contact_mail, label: 'Contact Us'),
                AccountTile(icon: Icons.logout, label: 'Log Out'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AccountTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const AccountTile({required this.icon, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // TODO: Add navigation or action
      },
    );
  }
}