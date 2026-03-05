import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cnp_navigator/screens/booking_page.dart';
import 'package:cnp_navigator/screens/chatbot/chatbot_page.dart';
import 'package:cnp_navigator/screens/rules/rules_page.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoSlideTimer;
  
  // Single selected activity (one booking at a time)
  String? _selectedActivity;

  final List<String> sliderImages = [
    "assets/images/cnp image.jpg",
    "assets/images/elephant.webp",
    "assets/images/leopard1.webp",
    "assets/images/rhino-1.jpg",
    "assets/images/royal bengal tiger.webp",
  ];

  String _getActivityImage(String activityName) {
    switch (activityName.toLowerCase()) {
      case 'jeep safari': return 'assets/images/jeep safari.jpg';
      case 'bird watching': return 'assets/images/bird watching.jpeg';
      case 'jungle walk': return 'assets/images/jungle walk.jpg';
      case 'canoe ride': return 'assets/images/canoe riding.jpg';
      case 'elephant safari': return 'assets/images/elephant.webp';
      case 'tharu cultural program': return 'assets/images/tharu dance.webp';
      case 'tharu museum': return 'assets/images/tharuculturalmuseum.webp';
      default: return 'assets/images/cnp image.jpg';
    }
  }

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        int next = (_currentPage + 1) % sliderImages.length;
        _pageController.animateToPage(next,
            duration: const Duration(milliseconds: 1000), curve: Curves.easeInOutQuart);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. STRETCHY HERO HEADER
              SliverAppBar(
                expandedHeight: 280.0,
                pinned: true,
                stretch: true,
                backgroundColor: const Color(0xFF1B5E20),
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: const Text('CNP EXPLOREE', 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1, fontSize: 16)),
                  background: _buildHeroSlider(),
                ),
                leading: const Icon(Icons.eco_rounded, color: Colors.white),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 24),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RulesPage())),
                  )
                ],
              ),

              // 2. TITLE SECTION
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Activities", 
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20))),
                      Text("Select your jungle adventures", 
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ),

              // 3. ACTIVITY LIST
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 110),
                sliver: _buildActivitiesFirebaseList(),
              ),
            ],
          ),

          // 4. FLOATING DOCK
          _buildFloatingActionUI(),
        ],
      ),
    );
  }

  Widget _buildHeroSlider() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (i) => setState(() => _currentPage = i),
          itemCount: sliderImages.length,
          itemBuilder: (context, index) => ShaderMask(
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.5)],
            ).createShader(rect),
            blendMode: BlendMode.darken,
            child: Image.asset(sliderImages[index], fit: BoxFit.cover),
          ),
        ),
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(sliderImages.length, (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 4,
              width: _currentPage == index ? 18 : 6,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
            )),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesFirebaseList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('activities').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
        
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Activity';
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                height: 85,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
                      child: Image.asset(_getActivityImage(name), width: 85, height: 85, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const Text("Chitwan Wildlife", style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: TextButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingPage(activityName: name),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20).withOpacity(0.1),
                          minimumSize: const Size(65, 34),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Book", style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              );
            },
            childCount: snapshot.data!.docs.length,
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionUI() {
    return Positioned(
      bottom: 20,
      left: 15,
      right: 15,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 55, width: 55,
            decoration: BoxDecoration(
              color: const Color(0xFFAD1457),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.2), blurRadius: 10)],
            ),
            child: IconButton(
              icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 24),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotPage())),
            ),
          ),
        ],
      ),
    );
  }
}