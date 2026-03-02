import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this to pubspec.yaml
import 'package:cnp_navigator/animal_detail_page.dart';
import 'package:cnp_navigator/database/db_animals.dart';
import 'package:cnp_navigator/screens/rules/rules_page.dart';
import 'package:cnp_navigator/screens/chatbot/chatbot_page.dart';
import '../../shared/common_layout.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  // --- STATE VARIABLES ---
  String? selectedCategory;
  String _searchText = "";
  final TextEditingController _searchController = TextEditingController();
  final AnimalQueryService _queryService = AnimalQueryService();

  late final Stream<List<Animal>> _animalsStream;

  // --- CAROUSEL STATE ---
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  final List<String> _carouselImages = [
    "assets/images/rhino-1.jpg",
    "assets/images/canoe riding.jpg",
    "assets/images/chitwan_swamp.jpg",
    "assets/images/deer.webp",
    "assets/images/jeep safari.jpg",
  ];

  @override
  void initState() {
    super.initState();
    _animalsStream = _queryService.streamAnimals();
    _startAutoSlider();
  }

  void _startAutoSlider() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int next = (_currentPage + 1) % _carouselImages.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- NAVIGATION HELPERS ---

  Future<void> _launchGoogleMaps() async {
    // Coordinates for Chitwan National Park
    final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=Chitwan+National+Park");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch maps");
    }
  }

  void _showAreaInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Park Geography", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
            const SizedBox(height: 15),
            const Text(
              "Chitwan National Park covers an area of 952.63 km². It was established in 1973 as Nepal's first national park.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: _launchGoogleMaps,
              icon: const Icon(Icons.map_rounded),
              label: const Text("Open in Google Maps"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSpeciesInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text("Wildlife Diversity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)))),
            const SizedBox(height: 15),
            const Text("The park is home to a vast range of biodiversity:"),
            const SizedBox(height: 10),
            _infoRow(Icons.check_circle, "68 species of mammals (Tigers, Rhinos)"),
            _infoRow(Icons.check_circle, "544 species of birds"),
            _infoRow(Icons.check_circle, "126 species of fish"),
            _infoRow(Icons.check_circle, "56 species of herpetofauna"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showRiversInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text("Major Waterways", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)))),
            const SizedBox(height: 15),
            _riverDetail("Narayani River", "Forms the western boundary of the park."),
            _riverDetail("Rapti River", "The northern border, famous for canoe safaris."),
            _riverDetail("Reu River", "Flows through the southern valley."),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Icon(icon, size: 18, color: Colors.green), const SizedBox(width: 10), Text(text)]),
    );
  }

  Widget _riverDetail(String name, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(desc, style: const TextStyle(color: Colors.black54, fontSize: 14)),
        ],
      ),
    );
  }

  // --- FILTER LOGIC ---
  void _clearFilters() {
    setState(() {
      selectedCategory = null;
      _searchText = "";
      _searchController.clear();
    });
  }

  List<Animal> _applyFilters(List<Animal> all) {
    return all.where((animal) {
      final matchesCategory = selectedCategory == null ||
          animal.category.toLowerCase() == selectedCategory!.toLowerCase();
      final matchesSearch = _searchText.isEmpty ||
          animal.name.toLowerCase().contains(_searchText.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      showHeader: false, 
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F5),
        floatingActionButton: _buildChatbotFAB(context),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 280.0,
              pinned: true,
              stretch: true,
              backgroundColor: const Color(0xFF1B5E20),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: const Text('EXPLORE CHITWAN',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 16)),
                background: _buildCarouselStack(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const RulesPage())),
                )
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    _buildFilterSection(),
                  ],
                ),
              ),
            ),

            // 3. UPDATED STATS SECTION
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildOverviewSection(),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 25, 16, 10),
                child: _buildSectionHeader('🐅 Wildlife Encyclopedia', 'Discover the park residents'),
              ),
            ),
            _buildWildlifeHorizontalList(),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSectionHeader('📅 Best Time to Visit', 'Sighting Forecast'),
                    const SizedBox(height: 10),
                    _buildBestTimeTable(),
                    const SizedBox(height: 25),
                    _buildSafetyBanner(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildOverviewSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _Stat(Icons.landscape, '952', 'km²', onTap: _showAreaInfo),
        _Stat(Icons.pets, '68', 'Species', onTap: _showSpeciesInfo),
        _Stat(Icons.water_drop, '3', 'Rivers', onTap: _showRiversInfo),
      ]),
    );
  }

  Widget _buildCarouselStack() {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _carouselImages.length,
          onPageChanged: (idx) {
            setState(() => _currentPage = idx);
          },
          itemBuilder: (ctx, i) => Image.asset(_carouselImages[i], fit: BoxFit.cover),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black87],
            ),
          ),
        ),
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _carouselImages.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: _currentPage == i ? 24 : 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(_currentPage == i ? 0.9 : 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchText = val),
        decoration: InputDecoration(
          hintText: 'Search species (e.g. Rhino)...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF4CAF50)),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.camera_alt_rounded, color: Colors.grey), onPressed: () {}),
              if (_searchText.isNotEmpty)
                IconButton(icon: const Icon(Icons.clear), onPressed: () {
                    _searchController.clear();
                    setState(() => _searchText = "");
                  },
                ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final categories = ['Mammal', 'Bird', 'Reptile', 'Amphibian'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Refine by Category', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
        if (selectedCategory != null || _searchText.isNotEmpty)
          TextButton(onPressed: _clearFilters, child: const Text('Reset', style: TextStyle(color: Colors.red))),
      ]),
      const SizedBox(height: 8),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: 8,
          children: categories.map((c) {
            return ChoiceChip(
              label: Text(c),
              selected: selectedCategory == c,
              onSelected: (s) => setState(() => selectedCategory = s ? c : null),
              selectedColor: const Color(0xFF4CAF50),
              labelStyle: TextStyle(
                  color: selectedCategory == c ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold),
            );
          }).toList(),
        ),
      ),
    ]);
  }

  Widget _buildWildlifeHorizontalList() {
    return SliverToBoxAdapter(
      child: StreamBuilder<List<Animal>>(
        stream: _animalsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No animals found."));
          final filteredList = _applyFilters(snapshot.data!);
          if (filteredList.isEmpty) return const SizedBox(height: 100, child: Center(child: Text("No matches found.")));

          return SizedBox(
            height: 250,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final animal = filteredList[index];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AnimalDetailPage(animal: {
                    'name': animal.name, 'category': animal.category, 'status': animal.status,
                    'diet': animal.diet, 'description': animal.description, 'mainImg': animal.mainImg, 'moreImg': animal.moreImg,
                  }))),
                  child: Container(
                    width: 220,
                    margin: const EdgeInsets.only(right: 15, bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(animal.mainImg, height: 130, width: double.infinity, fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(color: Colors.grey, height: 130)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(animal.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFF4CAF50).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(animal.status, style: const TextStyle(fontSize: 10, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatbotFAB(BuildContext context) {
    return Container(
      height: 55, width: 55,
      decoration: BoxDecoration(color: const Color(0xFFAD1457), borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.2), blurRadius: 10)]),
      child: IconButton(icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 24),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotPage())),
      ),
    );
  }

  Widget _buildBestTimeTable() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: const Column(children: [
        _SeasonRow('Oct - Mar', 'Peak Season - Best Visibility', Colors.green),
        Divider(height: 1),
        _SeasonRow('Apr - Jun', 'Safari Season - Tiger Sightings', Colors.orange),
      ]),
    );
  }

  Widget _buildSafetyBanner(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RulesPage())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)]), borderRadius: BorderRadius.circular(20)),
        child: const Row(children: [
          Icon(Icons.security, color: Colors.white), SizedBox(width: 15),
          Expanded(child: Text('Essential Safety Guide', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Icon(Icons.chevron_right, color: Colors.white),
        ]),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String sub) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20))),
      Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ]);
  }
}

// --- STAT WIDGET ---
class _Stat extends StatelessWidget {
  final IconData icon;
  final String val;
  final String label;
  final VoidCallback onTap;
  const _Stat(this.icon, this.val, this.label, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Icon(icon, color: Colors.green),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 10))
        ]),
      ),
    );
  }
}

class _SeasonRow extends StatelessWidget {
  final String date;
  final String desc;
  final Color color;
  const _SeasonRow(this.date, this.desc, this.color);
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(15), child: Row(children: [
          Container(width: 4, height: 18, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 15),
          Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(child: Text(desc, style: const TextStyle(fontSize: 12, color: Colors.black54))),
        ]));
  }
}