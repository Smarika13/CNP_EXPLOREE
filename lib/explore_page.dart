import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cnp_navigator/database/db_animals.dart';
import 'package:cnp_navigator/screens/booking_page.dart';
import 'package:cnp_navigator/screens/rules/rules_page.dart';
import 'package:flutter/material.dart';
import '../../shared/common_layout.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String? selectedCategory;
  String? selectedStatus;
  String? selectedDiet;
  List<String> selectedActivities = []; 

  final AnimalQueryService _queryService = AnimalQueryService();

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
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: Color(0xFFF5F2E7)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  _buildFilterHeader(),
                  const SizedBox(height: 8),

                  _buildFilterSection('Category', ['Mammal', 'Bird', 'Fish', 'Reptile', 'Amphibian', 'Trees', 'Butterfly'], selectedCategory, (val) => setState(() => selectedCategory = val)),
                  _buildFilterSection('Conservation Status', ['Critically Endangered', 'Endangered', 'Near Threatened', 'Vulnerable', 'Least Concern'], selectedStatus, (val) => setState(() => selectedStatus = val)),
                  _buildFilterSection('Diet Type', ['Herbivore', 'Carnivore', 'Omnivore'], selectedDiet, (val) => setState(() => selectedDiet = val)),

                  const SizedBox(height: 20),
                  _buildAnimalStreamList(),
                  const SizedBox(height: 20),
                  _buildActivitiesSection(context),
                  const SizedBox(height: 20),
                  _buildRulesCard(context),
                  const SizedBox(height: 120), // Space for floating button
                ],
              ),
            ),
          ),

          // MULTIPLE BOOKING CONFIRM BUTTON
          if (selectedActivities.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 10,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingPage (activityList: selectedActivities),
                    ),
                  );
                },
                child: Text(
                  'Book Selected Activities (${selectedActivities.length})', 
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search Animals...',
          filled: true,
          fillColor: const Color(0xFFECE5D8),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.filter_list, color: Color(0xFF2E7D32), size: 20),
              SizedBox(width: 6),
              Text('Filter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32))),
            ],
          ),
          if (selectedCategory != null || selectedStatus != null || selectedDiet != null)
            TextButton(onPressed: _clearFilters, child: const Text('Clear All', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

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
            children: options.map((option) {
              final isSelected = currentSelection == option;
              return FilterChip(
                label: Text(option, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                backgroundColor: const Color(0xFFECE5D8),
                selectedColor: const Color(0xFF81C784),
                labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF3E2723)),
                onSelected: (bool selected) => onSelected(selected ? option : null),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalStreamList() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Suggested for You', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
          const SizedBox(height: 10),
          StreamBuilder<List<Animal>>(
            stream: _queryService.streamAnimals(category: selectedCategory, status: selectedStatus, diet: selectedDiet),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final animals = snapshot.data ?? [];
              return SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: animals.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => _buildAnimalCard(animals[index]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalCard(Animal animal) {
    return Container(
      width: 150,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: Image.network(animal.mainImg, fit: BoxFit.cover, width: double.infinity))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(animal.name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(animal.status, style: const TextStyle(fontSize: 11, color: Colors.green))]),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Book Activities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('activities').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final name = data['name'] ?? 'Activity';
                  final isSelected = selectedActivities.contains(name);
                  return InkWell(
                    onTap: () => setState(() => isSelected ? selectedActivities.remove(name) : selectedActivities.add(name)),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF81C784) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected ? Border.all(color: const Color(0xFF2E7D32), width: 2) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.explore, color: isSelected ? Colors.white : const Color(0xFF2E7D32)),
                          const SizedBox(height: 5),
                          Text(name, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : Colors.black)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRulesCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: const Icon(Icons.rule, color: Colors.orange),
        title: const Text('Rules & Safety'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RulesPage())),
      ),
    );
  }
}