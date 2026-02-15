import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> categories = [
      "Mammal",
      "Bird",
      "Fish",
      "Reptile",
      "Amphibian"
    ];

    final List<String> conservationStatus = [
      "Endangered",
      "Vulnerable",
      "Least Concern",
      "Near Threatened",
      "Critically Endangered"
    ];

    final List<String> dietTypes = [
      "Herbivore",
      "Carnivore",
      "Omnivore",
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar with camera icon
              TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      // TODO: Implement camera scan
                    },
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Search by filter (plain text)
              Row(
                children: const [
                  Icon(Icons.filter_list, color: Color(0xFF4FBF26)),
                  SizedBox(width: 8),
                  Text(
                    "Search by filter",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4FBF26),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Category Section
              const Text(
                "Category",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return OutlinedButton(
                      onPressed: () {
                        // TODO: Filter by category
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4FBF26)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                      ),
                      child: Text(
                        categories[index],
                        style: const TextStyle(
                          color: Color(0xFF4FBF26),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Conservation Status Section
              const Text(
                "Conservation Status",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: conservationStatus.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return OutlinedButton(
                      onPressed: () {
                        // TODO: Filter by conservation status
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4FBF26)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                      ),
                      child: Text(
                        conservationStatus[index],
                        style: const TextStyle(
                          color: Color(0xFF4FBF26),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Diet Type Section
              const Text(
                "Diet Type",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: dietTypes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return OutlinedButton(
                      onPressed: () {
                        // TODO: Filter by diet type
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4FBF26)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0),
                      ),
                      child: Text(
                        dietTypes[index],
                        style: const TextStyle(
                          color: Color(0xFF4FBF26),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ================= KNOW ABOUT SECTION =================
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Discover CNP Life",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    height: 3,
                    width: 170,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4FBF26),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Discover the wildlife of Chitwan National Park. "
                        "Click on any category to explore more.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Placeholder for content below "Know About"
              const Expanded(
                child: Center(
                  child: Text(
                    "Content cards",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // ======================================================
            ],
          ),
        ),
      ),
    );
  }
}
