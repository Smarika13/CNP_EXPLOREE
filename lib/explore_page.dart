import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for Map Launching
import 'package:cnp_navigator/animal_detail_page.dart';
import 'package:cnp_navigator/database/db_animals.dart';
import 'package:cnp_navigator/screens/rules/rules_page.dart';
import 'package:cnp_navigator/screens/chatbot/chatbot_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String? selectedCategory;
  String? selectedTag;
  String _searchText = "";
  final TextEditingController _searchController = TextEditingController();
  final AnimalQueryService _queryService = AnimalQueryService();

  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<String> sliderImages = [
    "assets/images/rhino-1.jpg",
    "assets/images/canoe riding.jpg",
    "assets/images/chitwan_swamp.jpg",
    "assets/images/deer.webp",
    "assets/images/jeep safari.jpg",
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlider();
  }

  void _startAutoSlider() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int next = (_currentPage + 1) % sliderImages.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _stopAutoSlider() => _timer?.cancel();

  // --- NEW: Map Launcher Logic ---
  Future<void> _launchMap() async {
    // Exact coordinates for Chitwan National Park HQ
    const double lat = 27.5000;
    const double lng = 84.3333;
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  void _showDetailSheet(String title, Widget content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
            const Divider(),
            const SizedBox(height: 10),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color forestGreen = Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      floatingActionButton: _buildChatbotFAB(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            stretch: true,
            backgroundColor: forestGreen,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text('CNP EXPLORE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5, shadows: [Shadow(blurRadius: 12, color: Colors.black)])),
              background: _buildCarouselStack(),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSearchBar(forestGreen),
                  const SizedBox(height: 12),
                  _buildQuickSearchChips(forestGreen),
                  const SizedBox(height: 20),
                  _buildFilterSection(forestGreen),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildOverviewSection(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 25, 16, 10),
              child: _buildSectionHeader('🐅 Wildlife Encyclopedia', 
                selectedTag != null ? 'Showing $selectedTag residents' : 'Discover the park residents', 
                forestGreen),
            ),
          ),
          _buildWildlifeHorizontalList(),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSectionHeader('📅 Best Time to Visit', 'Sighting Forecast', forestGreen),
                  const SizedBox(height: 10),
                  _buildBestTimeTable(),
                  const SizedBox(height: 25),
                  _buildSafetyBanner(context, forestGreen),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselStack() {
    return Listener(
      onPointerDown: (_) => _stopAutoSlider(),
      onPointerUp: (_) => _startAutoSlider(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: sliderImages.length,
            physics: const AlwaysScrollableScrollPhysics(),
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemBuilder: (ctx, i) => Image.asset(sliderImages[i], fit: BoxFit.cover),
          ),
          const IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black38, Colors.transparent, Colors.black54])))),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color forestGreen) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() {
          _searchText = val;
          selectedTag = null;
        }),
        decoration: InputDecoration(
          hintText: 'Search species...',
          prefixIcon: Icon(Icons.search, color: forestGreen),
          suffixIcon: Icon(Icons.camera_alt_rounded, color: forestGreen),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
      ),
    );
  }

  Widget _buildQuickSearchChips(Color forestGreen) {
    final quickTags = ['Endangered', 'Predators', 'Herbivores', 'Rare'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: quickTags.map((tag) {
          final isSelected = selectedTag == tag;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(tag, style: const TextStyle(fontSize: 12)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedTag = selected ? tag : null;
                  _searchText = "";
                  _searchController.clear();
                });
              },
              selectedColor: forestGreen.withOpacity(0.2),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(color: isSelected ? forestGreen : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              side: BorderSide(color: isSelected ? forestGreen : Colors.grey.shade300),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterSection(Color forestGreen) {
    final categories = ['Mammal', 'Bird', 'Reptile', 'Amphibian'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((c) => Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ChoiceChip(
            label: Text(c),
            selected: selectedCategory == c,
            onSelected: (s) => setState(() => selectedCategory = s ? c : null),
            selectedColor: forestGreen,
            labelStyle: TextStyle(color: selectedCategory == c ? Colors.white : Colors.black),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _Stat(Icons.landscape, '952', 'km²', onTap: () {
          _showDetailSheet('Chitwan National Park Map', Column(
            children: [
              const Text('Nepal\'s first national park, stretching across 952.63 km² of subtropical lowland.', textAlign: TextAlign.center),
              const SizedBox(height: 15),
              // THE MAP IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  "https://whc.unesco.org/uploads/activities/documents/activity-558-1.jpg", 
                  height: 250, 
                  width: double.infinity, 
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.map_outlined, size: 100, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _launchMap,
                icon: const Icon(Icons.map_rounded),
                label: const Text('Open in Google Maps'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
              )
            ],
          ));
        }),
        _Stat(Icons.pets, '68', 'Species', onTap: () {
          _showDetailSheet('Park Species', const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('The park is a biodiversity hotspot:'),
              SizedBox(height: 10),
              Text('• 68 Mammal Species (including the Bengal Tiger)'),
              Text('• 544 Bird Species'),
              Text('• 126 Fish Species'),
              Text('• 56 Herpetofauna (Reptiles & Amphibians)'),
            ],
          ));
        }),
        _Stat(Icons.water_drop, '3', 'Rivers', onTap: () {
          _showDetailSheet('The Lifeline Rivers', const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('• Rapti River: Ideal for spotting crocodiles and birds.', style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            Text('• Narayani River: The deepest river in Nepal, forming the western boundary.', style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            Text('• Reu River: A smaller river running through the southern forests.', style: TextStyle(fontSize: 16)),
          ]));
        }),
      ]),
    );
  }

  Widget _buildWildlifeHorizontalList() {
    return SliverToBoxAdapter(
      child: StreamBuilder<List<Animal>>(
        stream: _queryService.streamAnimals(category: selectedCategory),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final filtered = snapshot.data!.where((animal) {
            final matchesText = animal.name.toLowerCase().contains(_searchText.toLowerCase());
            final matchesTag = selectedTag == null || 
                               animal.description.toLowerCase().contains(selectedTag!.toLowerCase());
            return matchesText && matchesTag;
          }).toList();

          if (filtered.isEmpty) {
            return const SizedBox(height: 100, child: Center(child: Text('No species found.')));
          }

          return SizedBox(
            height: 220,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final animal = filtered[i];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => AnimalDetailPage(animal: animal))),
                  child: Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3))]),
                    child: Column(
                      children: [
                        ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), child: Image.network(animal.mainImg, height: 120, width: 180, fit: BoxFit.cover)),
                        Padding(padding: const EdgeInsets.all(12.0), child: Text(animal.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
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

  Widget _buildChatbotFAB(BuildContext context) => FloatingActionButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotPage())), backgroundColor: const Color(0xFFAD1457), child: const Icon(Icons.chat_bubble_rounded, color: Colors.white));
  Widget _buildBestTimeTable() => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: const Column(children: [_SeasonRow('Oct - Mar', 'Peak Season', Colors.green), Divider(height: 1), _SeasonRow('Apr - Jun', 'Safari Season', Colors.orange)]));
  Widget _buildSafetyBanner(BuildContext context, Color forestGreen) => InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RulesPage())), child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: LinearGradient(colors: [forestGreen, const Color(0xFF2E7D32)]), borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.security, color: Colors.white), SizedBox(width: 15), Expanded(child: Text('Essential Safety Guide', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), Icon(Icons.chevron_right, color: Colors.white)])));
  Widget _buildSectionHeader(String title, String sub, Color forestGreen) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: forestGreen)), Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey))]);
}

class _Stat extends StatelessWidget {
  final IconData icon; final String val; final String label; final VoidCallback onTap;
  const _Stat(this.icon, this.val, this.label, {required this.onTap});
  @override build(BuildContext context) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(10), child: Padding(padding: const EdgeInsets.all(8.0), child: Column(children: [Icon(icon, color: const Color(0xFF1B5E20)), Text(val, style: const TextStyle(fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(fontSize: 10))])));
  }
}

class _SeasonRow extends StatelessWidget {
  final String date; final String desc; final Color color;
  const _SeasonRow(this.date, this.desc, this.color);
  @override build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(15), child: Row(children: [Container(width: 4, height: 18, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 15), Text(date, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 10), Expanded(child: Text(desc, style: const TextStyle(fontSize: 12, color: Colors.black54)))]));
  }
}