import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cnp_navigator/screens/booking_page.dart';
import 'package:cnp_navigator/screens/chatbot/chatbot_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoSlideTimer;
  String? _selectedActivity;

  final List<String> sliderImages = [
    "assets/images/cnp image.jpg",
    "assets/images/elephant.webp",
    "assets/images/leopard1.webp",
    "assets/images/rhino-1.jpg",
    "assets/images/royal bengal tiger.webp",
  ];

  String _getActivityKey(String activityName) {
    switch (activityName.toLowerCase()) {
      case 'jeep safari': return 'activity_jeep_safari';
      case 'bird watching': return 'activity_bird_watching';
      case 'elephant safari': return 'activity_elephant_safari';
      case 'jungle walk': return 'activity_jungle_walk';
      case 'canoe ride': return 'activity_canoe_ride';
      case 'tharu cultural program': return 'activity_tharu_cultural';
      case 'tharu museum': return 'activity_tharu_museum';
      default: return activityName;
    }
  }

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

  Future<void> _launchMapUrl() async {
    String mapUrl = 'https://www.google.com/maps/search/?api=1&query=Chitwan+National+Park';
    final doc = await FirebaseFirestore.instance.collection('settings').doc('location').get();
    if (doc.exists) {
      final stored = doc.data()?['mapUrl'] as String?;
      if (stored != null && stored.isNotEmpty) mapUrl = stored;
    }
    final uri = Uri.parse(mapUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch map URL');
    }
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
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. FIXED HERO SLIDER
              SizedBox(
                height: 260 + topPadding,
                child: Stack(
                  children: [
                    _buildHeroSlider(),
                    // Top bar overlay on the image
                    Positioned(
                      top: topPadding,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.eco_rounded, color: Colors.white),
                            Expanded(
                              child: Text(
                                'dashboard_title'.tr(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. FIXED "ACTIVITIES" HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('activities'.tr(),
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20))),
                          if (context.locale.languageCode == 'en')
                            Text('jungle_adventures'.tr(),
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _launchMapUrl,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on, color: Color(0xFF2E7D32), size: 18),
                            SizedBox(width: 4),
                            Text('Location', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. SCROLLABLE ACTIVITY LIST ONLY
              Expanded(child: _buildActivitiesFirebaseList()),
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
          bottom: 90,
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
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final seen = <String>{};
        final docs = snapshot.data!.docs.where((doc) {
          final d = doc.data() as Map<String, dynamic>;
          final name = (d['title'] ?? d['name']) as String?;
          if (name == null || name.trim().isEmpty) return false;
          return seen.add(name.trim().toLowerCase());
        }).toList()
          ..sort((a, b) {
            final nameA = ((a.data() as Map<String, dynamic>)['title'] ?? (a.data() as Map<String, dynamic>)['name']) as String;
            final nameB = ((b.data() as Map<String, dynamic>)['title'] ?? (b.data() as Map<String, dynamic>)['name']) as String;
            return nameA.compareTo(nameB);
          });
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 90),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final name = (data['title'] ?? data['name']) as String;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              height: 85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Row(
                children: [
                  // Green accent strip
                  Container(width: 4, color: const Color(0xFF4CAF50).withOpacity(0.7)),
                  data['imageUrl'] != null && (data['imageUrl'] as String).isNotEmpty
                      ? Image.network(data['imageUrl'] as String, width: 81, height: 85, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(_getActivityImage(name), width: 81, height: 85, fit: BoxFit.cover))
                      : Image.asset(_getActivityImage(name), width: 81, height: 85, fit: BoxFit.cover),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getActivityKey(name).tr(),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingPage(activityName: name),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withOpacity(0.45),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('book_now'.tr(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    letterSpacing: 0.5)),
                            const SizedBox(width: 5),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ),
            );
          },
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