import 'dart:async';
import 'package:cnp_navigator/admin_panel/screens/chatbot/chatbot_page.dart';
import 'package:cnp_navigator/admin_panel/screens/explore/explore_page.dart';
import 'package:cnp_navigator/admin_panel/screens/notice/notice_page.dart';
import 'package:cnp_navigator/admin_panel/screens/profile/profile_page.dart';
import 'package:cnp_navigator/admin_panel/screens/rules/rules_page.dart';
import 'package:flutter/material.dart';
import 'booking_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Missing variables that caused errors
  int _currentPage = 0;
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  Timer? _autoSlideTimer;

  // Example list of images - make sure these exist in your pubspec.yaml
  final List<String> sliderImages = [
    "assets/images/jeep safari.jpg",
    "assets/images/bird watching.jpeg",
    "assets/images/jungle walk.jpg",
  ];

  @override
  void initState() {
    super.initState();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _goToNextPage();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  void _goToNextPage() {
    if (!mounted) return;
    int nextPage = (_currentPage + 1) % sliderImages.length;
    if (_currentPage == sliderImages.length - 1) {
      _pageController.jumpToPage(nextPage);
    } else {
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
    setState(() => _currentPage = nextPage);
  }

  void _goToPrevPage() {
    int prevPage = (_currentPage - 1 + sliderImages.length) % sliderImages.length;
    _pageController.animateToPage(
      prevPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = prevPage);
  }

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56), // Standard height is 56
        child: AppBar(
          backgroundColor: const Color(0xFF4FBF26),
          centerTitle: true,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco,
                size: 20,
                color: Color(0xFF4FBF26),
              ),
            ),
          ),
          title: const Text(
            "CNP EXPLORE",
            style: TextStyle(fontSize: 17, color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, size: 24, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RulesPage()),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(),
          const ExplorePage(),
          const NoticePage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        selectedItemColor: const Color(0xFF4FBF26),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notice"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: const Color(0xFFD81B60),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatbotPage()),
          );
        },
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: sliderImages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return Image.asset(
                    sliderImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
              // Left Arrow
              Positioned(
                left: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.5),
                    radius: 15,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 16,
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                      onPressed: _goToPrevPage,
                    ),
                  ),
                ),
              ),
              // Right Arrow
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.5),
                    radius: 15,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 16,
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                      onPressed: _goToNextPage,
                    ),
                  ),
                ),
              ),
              // Indicators
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(sliderImages.length, (index) {
                    bool isActive = _currentPage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.white54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Activities",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            children: [
              activityCard(context, title: "Jeep Safari", image: "assets/images/jeep safari.jpg"),
              activityCard(context, title: "Bird Watching", image: "assets/images/bird watching.jpeg"),
              activityCard(context, title: "Jungle Walk", image: "assets/images/jungle walk.jpg"),
              activityCard(context, title: "Tharu Museum", image: "assets/images/tharuculturalmuseum.webp"),
              activityCard(context, title: "Elephant Safari", image: "assets/images/elephant_safari.webp"),
              activityCard(context, title: "Tharu Cultural Program", image: "assets/images/tharu dance.webp"),
              activityCard(context, title: "Canoe Ride", image: "assets/images/canoe riding.jpg"),
            ],
          ),
        ),
      ],
    );
  }

  Widget activityCard(BuildContext context, {required String title, required String image}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(image, height: 70, width: 70, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookingPage(activityName: title)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FBF26),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Book", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}