import 'dart:async';
import 'package:flutter/material.dart';
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

  // Single stream, created once, never recreated.
  // All filtering is done client-side so the stream is always stable.
  late final Stream<List<Animal>> _animalsStream;

  // --- CAROUSEL STATE ---
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  final List<String> _carouselImages = [
    "assets/images/rhino-1.jpg",
    "assets/images/canoe riding.jpg",
    "assets/images/chitwan_swamp.jpg",
    "assets/images/der.webp",
    "assets/images/jeep safari.jpg",
  ];

  @override
  void initState() {
    super.initState();
    // No category argument — fetch everything once, filter client-side
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

  void _clearFilters() {
    setState(() {
      selectedCategory = null;
      _searchText = "";
      _searchController.clear();
    });
  }

  // Client-side filter applied to the full list from the stream
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
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F5),
        floatingActionButton: _buildChatbotFAB(context),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. INTERACTIVE CAROUSEL HEADER
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

            // 2. SEARCH & CATEGORY FILTERS
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

            // 3. STATS SECTION
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildOverviewSection(),
              ),
            ),

            // 4. FILTERED WILDLIFE LIST (Horizontal)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 25, 16, 10),
                child: _buildSectionHeader('🐅 Wildlife Encyclopedia', 'Discover the park residents'),
              ),
            ),
            _buildWildlifeHorizontalList(),

            // 5. SEASONAL GUIDE
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

  // --- COMPONENT: INTERACTIVE CAROUSEL ---
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

  // --- COMPONENT: SEARCH BAR WITH CAMERA ---
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
              IconButton(
                icon: const Icon(Icons.camera_alt_rounded, color: Colors.grey),
                onPressed: () {
                  // TODO: Implement Visual/Image Search
                },
              ),
              if (_searchText.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
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

  // --- COMPONENT: CATEGORY FILTERS ---
  Widget _buildFilterSection() {
    final categories = ['Mammal', 'Bird', 'Reptile', 'Amphibian'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Refine by Category',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
        if (selectedCategory != null || _searchText.isNotEmpty)
          TextButton(
              onPressed: _clearFilters,
              child: const Text('Reset', style: TextStyle(color: Colors.red))),
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

  // --- COMPONENT: WILDLIFE LIST (CLIENT-SIDE FILTERED) ---
  Widget _buildWildlifeHorizontalList() {
    return SliverToBoxAdapter(
      child: StreamBuilder<List<Animal>>(
        stream: _animalsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator()));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No animals found."));
          }

          final filteredList = _applyFilters(snapshot.data!);

          if (filteredList.isEmpty) {
            return const SizedBox(
                height: 100,
                child: Center(child: Text("No matches found.")));
          }

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
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AnimalDetailPage(
                                animal: {
                                  'name': animal.name,
                                  'category': animal.category,
                                  'status': animal.status,
                                  'diet': animal.diet,
                                  'description': animal.description,
                                  'mainImg': animal.mainImg,
                                  'moreImg': animal.moreImg,
                                },
                              ))),
                  child: Container(
                    width: 220,
                    margin: const EdgeInsets.only(right: 15, bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                          child: Image.network(animal.mainImg,
                              height: 130,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) =>
                                  Container(color: Colors.grey, height: 130)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(animal.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(animal.status,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF2E7D32),
                                        fontWeight: FontWeight.bold)),
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

  // --- STATS, BUTTONS & OTHER UI ---
  Widget _buildOverviewSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration:
          BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _Stat(Icons.landscape, '952', 'km²'),
        _Stat(Icons.pets, '68', 'Species'),
        _Stat(Icons.water_drop, '3', 'Rivers'),
      ]),
    );
  }

  Widget _buildChatbotFAB(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 60,
      child: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ChatbotPage())),
        backgroundColor: const Color(0xFFAD1457),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildBestTimeTable() {
    return Container(
      decoration:
          BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: const Column(children: [
        _SeasonRow('Oct - Mar', 'Peak Season - Best Visibility', Colors.green),
        Divider(height: 1),
        _SeasonRow('Apr - Jun', 'Safari Season - Tiger Sightings', Colors.orange),
      ]),
    );
  }

  Widget _buildSafetyBanner(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => const RulesPage())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            gradient:
                const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)]),
            borderRadius: BorderRadius.circular(20)),
        child: const Row(children: [
          Icon(Icons.security, color: Colors.white),
          SizedBox(width: 15),
          Expanded(
              child: Text('Essential Safety Guide',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
          Icon(Icons.chevron_right, color: Colors.white),
        ]),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String sub) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B5E20))),
      Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ]);
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String val;
  final String label;
  const _Stat(this.icon, this.val, this.label);
  @override
  build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: Colors.green),
      Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(fontSize: 10))
    ]);
  }
}

class _SeasonRow extends StatelessWidget {
  final String date;
  final String desc;
  final Color color;
  const _SeasonRow(this.date, this.desc, this.color);
  @override
  build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(15),
        child: Row(children: [
          Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 15),
          Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(desc,
                  style: const TextStyle(fontSize: 12, color: Colors.black54))),
        ]));
  }
}