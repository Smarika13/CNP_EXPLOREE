import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cnp_navigator/animal_detail_page.dart';
import 'package:cnp_navigator/database/db_animals.dart';
import 'package:cnp_navigator/screens/rules/rules_page.dart';
import 'package:cnp_navigator/screens/chatbot/chatbot_page.dart';
import 'package:cnp_navigator/data/cnp_species_data.dart';
import '../../shared/common_layout.dart';
import 'screens/animal_detector/animal_detector_sheet.dart';

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

  List<Animal> _allAnimals = [];
  bool _loading = true;

  // Firestore species added by admin (merged with local dart data)
  List<({SpeciesInfo sp, String key, String category})> _firestoreIndex = [];

  // Pre-built flat search index: species + lowercase searchable key + category
  late List<({SpeciesInfo sp, String key, String category})> _searchIndex;

  @override
  void initState() {
    super.initState();
    // Build search index from local dart data
    _searchIndex = [
      for (final entry in allSpecies.entries)
        for (final sp in entry.value)
          (
            sp: sp,
            category: entry.key,
            key: '${sp.englishName} ${sp.nepaliName}'.toLowerCase(),
          ),
    ];
    _queryService.streamAnimals().listen((animals) {
      if (mounted) setState(() { _allAnimals = animals; _loading = false; });
    });
    // Subscribe to Firestore species added by admin
    FirebaseFirestore.instance.collection('species').snapshots().listen((snap) {
      final localKeys = {
        for (final entry in allSpecies.entries)
          for (final sp in entry.value) sp.englishName.toLowerCase()
      };
      // Only include species NOT already in the local dart data
      final newEntries = snap.docs
          .where((d) => !localKeys.contains((d['englishName'] as String).toLowerCase()))
          .map((d) => (
                sp: SpeciesInfo(
                  englishName: d['englishName'] ?? '',
                  nepaliName: d['nepaliName'] ?? '',
                  scientificName: d['scientificName'] ?? '',
                  habitat: d['habitat'] ?? '',
                  conservationStatus: d['conservationStatus'] ?? 'Least Concern',
                  description: d['description'] ?? '',
                  funFact: d['funFact'] ?? '',
                ),
                category: d['category'] as String? ?? '',
                key: '${d['englishName']} ${d['nepaliName']}'.toLowerCase(),
              ))
          .toList();
      if (mounted) setState(() => _firestoreIndex = newEntries);
    });
  }

  @override
  void dispose() {
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
            const Text("The park is home to 794 species across all categories:"),
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
        appBar: AppBar(
          backgroundColor: const Color(0xFF1B5E20),
          title: const Text(
            'EXPLORE CHITWAN',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              fontSize: 16,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FIXED: Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: _buildSearchBar(),
            ),
            // FIXED: Filter chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: _buildFilterSection(),
            ),
            // SCROLLABLE: Everything below
            Expanded(
              child: (selectedCategory != null || _searchText.isNotEmpty)
                  ? _buildVerticalSpeciesList()
                  : ListView(
                      padding: const EdgeInsets.only(bottom: 90),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildOverviewSection(),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildRulesBanner(context),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildSectionHeader('🐅 Wildlife Encyclopedia', 'Discover the park residents'),
                        ),
                        const SizedBox(height: 10),
                        _buildWildlifeHorizontalList(),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildSectionHeader('📅 Best Time to Visit', 'Sighting Forecast'),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildBestTimeTable(),
                        ),
                      ],
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
        _Stat(Icons.pets, '794', 'Species', onTap: _showSpeciesInfo),
        _Stat(Icons.water_drop, '3', 'Rivers', onTap: _showRiversInfo),
      ]),
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
              IconButton(
            icon: const Icon(Icons.camera_alt_rounded, color: Colors.grey),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const AnimalDetectorSheet(),
              );
            },
          ),
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('categories')
          .orderBy('order')
          .snapshots(),
      builder: (context, snapshot) {
        final List<({String name, String type})> all = snapshot.hasData
            ? snapshot.data!.docs
                .where((d) => (d['isActive'] as bool?) == true)
                .map((d) => (
                      name: d['name'] as String,
                      type: (d['type'] as String?) ?? 'fauna',
                    ))
                .toList()
            : [
                (name: 'Mammal',    type: 'fauna'),
                (name: 'Bird',      type: 'fauna'),
                (name: 'Fish',      type: 'fauna'),
                (name: 'Reptile',   type: 'fauna'),
                (name: 'Amphibian', type: 'fauna'),
                (name: 'Butterfly', type: 'fauna'),
                (name: 'Plant',     type: 'flora'),
              ];

        final fauna = all.where((c) => c.type == 'fauna').map((c) => c.name).toList();
        final flora = all.where((c) => c.type == 'flora').map((c) => c.name).toList();

        Widget chipRow(List<String> cats, Color selectedColor) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cats.map((c) => ChoiceChip(
                    label: Text(c),
                    selected: selectedCategory == c,
                    onSelected: (s) => setState(() => selectedCategory = s ? c : null),
                    selectedColor: selectedColor,
                    labelStyle: TextStyle(
                        color: selectedCategory == c ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold),
                  )).toList(),
            );

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Flora & Fauna', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1B5E20))),
            if (selectedCategory != null || _searchText.isNotEmpty)
              TextButton(onPressed: _clearFilters, child: const Text('Reset', style: TextStyle(color: Colors.red))),
          ]),
          if (fauna.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('🐾 Fauna', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF2E7D32))),
            const SizedBox(height: 6),
            chipRow(fauna, const Color(0xFF4CAF50)),
          ],
          if (flora.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text('🌿 Flora', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF388E3C))),
            const SizedBox(height: 6),
            chipRow(flora, const Color(0xFF66BB6A)),
          ],
        ]);
      },
    );
  }

  Widget _buildWildlifeHorizontalList() {
    if (_loading) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    }
    if (_allAnimals.isEmpty) return const Center(child: Text("No animals found."));

    return SizedBox(
      height: 250,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _allAnimals.length,
        itemBuilder: (context, index) {
          final animal = _allAnimals[index];
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
  }

  Widget _buildVerticalSpeciesList() {
    final q = _searchText.toLowerCase();

    // Combine local dart index with Firestore-added species
    final combinedIndex = [..._searchIndex, ..._firestoreIndex];

    List<SpeciesInfo> speciesList;
    if (_searchText.isNotEmpty) {
      speciesList = combinedIndex
          .where((e) =>
              e.key.contains(q) &&
              (selectedCategory == null || e.category == selectedCategory))
          .map((e) => e.sp)
          .toList();
    } else {
      final local = allSpecies[selectedCategory] ?? [];
      final fromFirestore = _firestoreIndex
          .where((e) => e.category == selectedCategory)
          .map((e) => e.sp)
          .toList();
      speciesList = [...local, ...fromFirestore];
    }

    if (speciesList.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            selectedCategory != null
                ? 'No $selectedCategory species found.'
                : 'No matches found.',
            style: const TextStyle(color: Colors.black54, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ]),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            '${speciesList.length} species${selectedCategory != null ? ' in $selectedCategory' : ' found'}',
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF1B5E20), fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
            physics: const BouncingScrollPhysics(),
            itemCount: speciesList.length,
            itemBuilder: (context, index) {
              final sp = speciesList[index];
              final norm = normalizeStatus(sp.conservationStatus);
              final color = statusColors[norm] ?? const Color(0xFF388E3C);
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => _SpeciesDetailPage(species: sp)),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                  ),
                  child: Row(children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.eco_rounded, color: color, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sp.englishName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(sp.nepaliName,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(norm,
                                style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.black26),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
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

  Widget _buildRulesBanner(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RulesPage())),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
              child: const Icon(Icons.shield_outlined, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Park Rules & Safety', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 2),
                  Text('Read before your visit', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
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

// --- SPECIES DETAIL PAGE (static data with fun facts) ---
class _SpeciesDetailPage extends StatelessWidget {
  final SpeciesInfo species;
  const _SpeciesDetailPage({required this.species});

  @override
  Widget build(BuildContext context) {
    final norm = normalizeStatus(species.conservationStatus);
    final color = statusColors[norm] ?? const Color(0xFF388E3C);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: Text(species.englishName,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.circle, size: 10, color: color),
              const SizedBox(width: 6),
              Text(norm, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 16),
          // Names card
          _DetailCard(children: [
            _DetailRow(Icons.translate_rounded, 'Nepali Name', species.nepaliName),
            _DetailRow(Icons.science_rounded, 'Scientific Name', species.scientificName,
                italic: true),
            _DetailRow(Icons.place_rounded, 'Habitat', species.habitat),
          ]),
          const SizedBox(height: 14),
          // Description
          _SectionTitle('About'),
          const SizedBox(height: 8),
          Text(species.description,
              style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.55)),
          const SizedBox(height: 20),
          // Fun fact
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text('Fun Fact', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ]),
              const SizedBox(height: 10),
              Text(species.funFact,
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.55)),
            ]),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
      child: Column(
        children: children.expand((w) => [w, if (w != children.last) const Divider(height: 16)]).toList(),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool italic;
  const _DetailRow(this.icon, this.label, this.value, {this.italic = false});
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: const Color(0xFF4CAF50)),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
        Text(value, style: TextStyle(fontSize: 14, fontStyle: italic ? FontStyle.italic : FontStyle.normal)),
      ]),
    ]);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20)));
  }
}