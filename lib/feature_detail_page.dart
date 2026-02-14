import 'package:flutter/material.dart';
import 'ParkFeature.dart'; // Only import the model to avoid duplicate class errors

class FeatureDetailPage extends StatelessWidget {
  final ParkFeature feature;

  const FeatureDetailPage({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- 1. EXPANDING IMAGE HEADER (SliverAppBar) ---
          SliverAppBar(
            expandedHeight: 350.0,
            pinned: true,
            stretch: true,
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: const Color(0xFF1B5E20),
            // Action Button for Sharing
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded),
                tooltip: 'Share',
                onPressed: () {
                  // You can implement the 'share' package here later
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sharing ${feature.title}...')),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              title: Text(
                feature.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [
                    Shadow(blurRadius: 12, color: Colors.black),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    feature.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  ),
                  // Bottom-to-top gradient to make the white title readable
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 2. CONTENT AREA ---
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Header
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.green, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Main Description
                    Text(
                      feature.description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.7,
                        color: Colors.black87,
                        letterSpacing: 0.3,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    const Divider(thickness: 1.2),
                    const SizedBox(height: 24),

                    // Highlights Header
                    const Text(
                      'Key Highlights',
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Maps each highlight string to a bullet-point row
                    ...feature.highlights.map((h) => _buildHighlightRow(h)),

                    const SizedBox(height: 48),
                    
                    // Styled "Back" Navigation Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        label: const Text(
                          'Back to Dashboard',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // --- HELPER: Bullet Point Row Widget ---
  Widget _buildHighlightRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.green, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}