import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rules & Safety Measures"),
        backgroundColor: const Color(0xFF4FBF26),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('park_rules').orderBy('timestamp').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final allRules = snapshot.data?.docs ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                "Rules & Safety Measures in Chitwan National Park",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              _buildSectionCard("Inside the Jungle", Colors.green, allRules),
              _buildSectionCard("Safety Measures Inside Jungle", Colors.redAccent, allRules),
              _buildSectionCard("Outside the Jungle", Colors.green, allRules),
              _buildSectionCard("Safety Measures Outside Jungle", Colors.redAccent, allRules),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(String title, Color color, List<QueryDocumentSnapshot> allDocs) {
    // Filter docs for this specific section
    final sectionDocs = allDocs.where((doc) => doc['section'] == title).toList();

    if (sectionDocs.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 12),
            ...sectionDocs.map((doc) => _ruleItem(doc['text'])),
          ],
        ),
      ),
    );
  }

  Widget _ruleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("•  ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.black87))),
        ],
      ),
    );
  }
}