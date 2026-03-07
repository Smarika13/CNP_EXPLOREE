import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'explore_page.dart';
import 'notice_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    ExplorePage(),
    NoticePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'nav_home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore),
            label: 'nav_explore'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications),
            label: 'nav_notices'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'nav_account'.tr(),
          ),
        ],
      ),
    );
  }
}

