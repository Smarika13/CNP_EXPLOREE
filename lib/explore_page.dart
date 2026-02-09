import 'package:cnp_navigator/database/db_animals.dart';
import 'package:cnp_navigator/screens/booking_page.dart';
import 'package:cnp_navigator/screens/rules/rules_page.dart';
import 'package:flutter/material.dart';
 // Make sure this path matches your file structure

import '../shared/common_layout.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  // 1. STATE VARIABLES FOR FILTERING
  String? selectedCategory;
  String? selectedStatus;
  String? selectedDiet;
  
  final AnimalQueryService _queryService = AnimalQueryService();

  // Helper to reset all filters
  void _clearFilters() {
    setState(() {
      selectedCategory = null;
      selectedStatus = null;
      selectedDiet = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F2E7),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              _buildFilterHeader(),
              const SizedBox(height: 8),

              // CATEGORY SECTION
              _buildFilterSection('Category', [
                'Mammal', 'Bird', 'Fish', 'Reptile', 'Amphibian', 'Trees', 'Butterfly',
              ], selectedCategory, (val) => setState(() => selectedCategory = val)),

              // CONSERVATION SECTION
              _buildFilterSection('Conservation Status', [
                'Critically Endangered', 'Endangered', 'Near Threatened', 'Vulnerable', 'Least Concern',
              ], selectedStatus, (val) => setState(() => selectedStatus = val)),

              // DIET SECTION
              _buildFilterSection('Diet Type', [
                'Herbivore', 'Carnivore', 'Omnivore',
              ], selectedDiet, (val) => setState(() => selectedDiet = val)),

              const SizedBox(height: 20),
              
              // 2. THE DYNAMIC DATABASE LIST
              _buildAnimalStreamList(),
              
              const SizedBox(height: 20),
              _buildActivitiesSection(context),
              const SizedBox(height: 20),
              _buildRulesCard(context),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // Header with Clear Button
  Widget _buildFilterHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.filter_list, color: Color(0xFF2E7D32), size: 20),
              SizedBox(width: 6),
              Text('Filter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32))),
            ],
          ),
          if (selectedCategory != null || selectedStatus != null || selectedDiet != null)
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear All', style: TextStyle(color: Colors.redAccent)),
            ),
        ],
      ),
    );
  }

  // DATABASE FETCHING WIDGET
  Widget _buildAnimalStreamList() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suggested for You',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<Animal>>(
            stream: _queryService.streamAnimals(
              category: selectedCategory,
              status: selectedStatus,
              diet: selectedDiet,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final animals = snapshot.data ?? [];
              
              if (animals.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No animals found with these filters."),
                  ),
                );
              }

              return SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: animals.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final animal = animals[index];
                    return _buildAnimalCard(animal);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // DATA CARD
  Widget _buildAnimalCard(Animal animal) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                animal.mainImg,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                ),
                Text(
                  animal.status,
                  style: const TextStyle(fontSize: 11, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SEARCH BAR
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          filled: true,
          fillColor: const Color(0xFFECE5D8),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // CHIP GENERATOR
  Widget _buildFilterSection(String title, List<String> options, String? currentSelection, Function(String?) onSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 0,
            children: options.map((option) {
              final isSelected = currentSelection == option;
              return FilterChip(
                label: Text(option, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                backgroundColor: const Color(0xFFECE5D8),
                selectedColor: const Color(0xFF81C784),
                labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF3E2723)),
                onSelected: (bool selected) {
                  onSelected(selected ? option : null);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ACTIVITIES LIST
  Widget _buildActivitiesSection(BuildContext context) {
    final activities = [
      {'name': 'Jeep Safari', 'icon': Icons.directions_car},
      {'name': 'Canoe Ride', 'icon': Icons.directions_boat},
      {'name': 'Jungle Walk', 'icon': Icons.directions_walk},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('Book Activities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: activities.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingPage(activityName: activities[index]['name'] as String))),
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(activities[index]['icon'] as IconData, color: const Color(0xFF2E7D32)),
                      Text(activities[index]['name'] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // RULES CARD
  Widget _buildRulesCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: const Icon(Icons.rule, color: Colors.orange),
        title: const Text('Rules & Safety', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Read before your visit'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RulesPage())),
      ),
    );
  }
}