import 'package:firebase_auth/firebase_auth.dart'; // REQUIRED FOR LOGOUT
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// Ensure these paths match your folder structure
import 'dashboard/dashboard_page.dart';
import 'bookings/bookings_page.dart';
import 'users/users_page.dart';
import 'activities/activities_page.dart';
import 'reports/reports_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;
  late final AudioPlayer _audioPlayer;

  // List of sub-pages for the bottom navigation
  final List<Widget> _pages = [
    const DashboardPage(),
    const AdminBookingsPage(),
    const UsersPage(),
    const ActivitiesPage(),
    ReportsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  void _playBirdChirp() async {
    try {
      await _audioPlayer.play(AssetSource('music/birds_chirping.mp3'));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  // SIGN OUT FUNCTION
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    // Your AuthWrapper will automatically see the 'null' user 
    // and switch the screen back to the Login Page.
  }

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4FBF26),
        centerTitle: true,
        leading: GestureDetector(
          onTap: _playBirdChirp,
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco,
                size: 28,
                color: Color(0xFF4FBF26),
              ),
            ),
          ),
        ),
        title: const Text(
          "CNP EXPLOREE",
          style: TextStyle(fontSize: 17, color: Colors.white),
        ),
        // ADDED LOGOUT BUTTON HERE
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        selectedItemColor: const Color(0xFF4FBF26),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.book_online), label: "Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.local_activity), label: "Activities"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Reports"),
        ],
      ),
    );
  }
}