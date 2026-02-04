import 'package:flutter/material.dart';

import 'screens/booking_page.dart';
import 'screens/rules/rules_page.dart';
import 'shared/common_layout.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

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
            _buildFilterLabel(),
            const SizedBox(height: 8),

            // Category Section
            _buildFilterSection('Category', [
              'Mammal',
              'Bird',
              'Fish',
              'Reptile',
              'Amphibian',
              'Trees',      // changed from Plant → Trees
              'Butterfly',  // added
            ]),

            // Conservation Status Section (all items together)
            _buildFilterSection('Conservation Status', [
              'Critically Endangered',  // added
              'Endangered',
              'Near Threatened',        // added
              'Vulnerable',
              'Least Concern',
            ]),

            // Diet Type Section
            _buildFilterSection('Diet Type', [
              'Herbivore',
              'Carnivore',
              'Omnivore',
            ]),

            const SizedBox(height: 20),
              _buildActivitiesSection(context),
              const SizedBox(height: 20),
              _buildSuggestedSection(),
              const SizedBox(height: 20),
              _buildRulesCard(context),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // Search Bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          filled: true,
          fillColor: const Color(0xFFECE5D8),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF2E7D32),
          ),
          suffixIcon: IconButton(
            icon: const Icon(
              Icons.camera_alt,
              color: Color(0xFF2E7D32),
            ),
            onPressed: () {},
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // Filter Label (non-clickable)
  Widget _buildFilterLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: const [
          Icon(
            Icons.filter_list,
            color: Color(0xFF2E7D32),
            size: 20,
          ),
          SizedBox(width: 6),
          Text(
            'Filter',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  // Generic Filter Section
  Widget _buildFilterSection(String title, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: options.map((option) {
              return FilterChip(
                label: Text(option),
                selected: false,
                backgroundColor: const Color(0xFFECE5D8),
                selectedColor: const Color(0xFF81C784),
                labelStyle: const TextStyle(color: Color(0xFF3E2723)),
                onSelected: (_) {},
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Suggested Section
  Widget _buildSuggestedSection() {
    final suggestions = ['Asian Elephant', 'Bengal Tiger', 'Hornbill'];
    final icons = [Icons.forest, Icons.pets, Icons.landscape];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suggested for You',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return Container(
                  width: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECE5D8),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 6),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[index],
                        size: 40,
                        color: const Color(0xFF2E7D32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        suggestions[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Activities Section
  Widget _buildActivitiesSection(BuildContext context) {
    final activities = [
      {'name': 'Jeep Safari', 'icon': Icons.directions_car},
      {'name': 'Elephant Safari', 'icon': Icons.pets},
      {'name': 'Bird Watching', 'icon': Icons.visibility},
      {'name': 'Jungle Walk', 'icon': Icons.directions_walk},
      {'name': 'Canoe Ride', 'icon': Icons.directions_boat},
      {'name': 'Tharu Cultural Program', 'icon': Icons.music_note},
    ];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Book Activities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: activities.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingPage(
                          activityName: activity['name'] as String,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 6),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          activity['icon'] as IconData,
                          size: 40,
                          color: const Color(0xFF2E7D32),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activity['name'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3E2723),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Rules Card
  Widget _buildRulesCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RulesPage()),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.rule,
                    color: Colors.orange,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rules & Safety Measures',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Important guidelines for visiting the park',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}