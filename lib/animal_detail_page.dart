import 'package:cnp_navigator/database/db_animals.dart';
import 'package:flutter/material.dart';

class AnimalDetailPage extends StatelessWidget {
  final Animal animal;

  const AnimalDetailPage({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2E7),
      body: CustomScrollView(
        slivers: [
          // 1. ANIMAL IMAGE HEADER
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: const Color(0xFF2E7D32),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: animal.name, // Matches the tag in ExplorePage
                child: Image.network(
                  animal.mainImg,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 2. ANIMAL DETAILS CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          animal.name,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ),
                      _buildBadge(animal.category ?? 'Unknown', Colors.green),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Conservation Status
                  Row(
                    children: [
                      const Icon(Icons.security, size: 18, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        "Status: ${animal.status}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 40, thickness: 1),

                  // Description Section
                  const Text(
                    "About the Species",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    animal.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Quick Facts Card (Pulling from Firebase fields if they exist)
                  // If your Animal model has fields like diet/habitat, you can add them here
                  _buildQuickFacts(),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI Helper: Status/Category Badge
  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  // UI Helper: Quick Facts Grid
  Widget _buildQuickFacts() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _factRow(Icons.location_on, "Habitat", "Subtropical Jungles"),
          const Divider(),
          _factRow(Icons.restaurant, "Diet", "Herbivore / Carnivore"),
          const Divider(),
          _factRow(Icons.visibility, "Sightings", "Common in Summer"),
        ],
      ),
    );
  }

  Widget _factRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 20),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}