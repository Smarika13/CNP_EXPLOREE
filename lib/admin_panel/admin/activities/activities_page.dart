import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_activity_page.dart';
import 'edit_activity_page.dart';

const _defaultActivities = [
  {
    "title": "Jeep Safari",
    "image": "assets/images/jeep safari.jpg",
    "domestic": 500,
    "saarc": 1500,
    "tourist": 3500,
    "timeSlots": ["6–10 AM", "2–5 PM"],
  },
  {
    "title": "Bird Watching",
    "image": "assets/images/bird watching.jpeg",
    "domestic": 3000,
    "saarc": 5500,
    "tourist": 6500,
    "timeSlots": ["6–10 AM", "2–5 PM"],
  },
  {
    "title": "Jungle Walk",
    "image": "assets/images/jungle walk.jpg",
    "domestic": 5000,
    "saarc": 10000,
    "tourist": 12500,
    "timeSlots": ["6–10 AM", "2–5 PM"],
  },
  {
    "title": "Tharu Museum",
    "image": "assets/images/tharuculturalmuseum.webp",
    "domestic": 200,
    "saarc": 400,
    "tourist": 400,
    "timeSlots": ["10:00 AM - 10:30 AM", "10:30 AM - 11:00 AM", "11:00 AM - 11:30 AM"],
  },
  {
    "title": "Elephant Safari",
    "image": "assets/images/elephant_safari.webp",
    "domestic": 1650,
    "saarc": 4000,
    "tourist": 5000,
    "timeSlots": ["6–10 AM", "2–5 PM"],
  },
  {
    "title": "Tharu Cultural Program",
    "image": "assets/images/tharu dance.webp",
    "domestic": 200,
    "saarc": 300,
    "tourist": 300,
    "timeSlots": ["7–8 PM"],
  },
  {
    "title": "Canoe Ride",
    "image": "assets/images/canoe riding.jpg",
    "domestic": 500,
    "saarc": 600,
    "tourist": 700,
    "timeSlots": ["6–10 AM", "2–5 PM"],
  },
];

Future<void> _seedActivities(BuildContext context) async {
  final col = FirebaseFirestore.instance.collection('activities');
  final batch = FirebaseFirestore.instance.batch();
  for (final a in _defaultActivities) {
    batch.set(col.doc(), {
      ...a,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('7 default activities added to Firestore!')),
    );
  }
}

class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('activities')
          .orderBy('title')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F5),
          body: docs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_activity_outlined,
                          size: 56, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('No activities yet.',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Load Default Activities'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _seedActivities(context),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _ActivityCard(
                      docId: doc.id,
                      data: data,
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddActivityPage()),
            ),
          ),
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  const _ActivityCard({required this.docId, required this.data});

  @override
  Widget build(BuildContext context) {
    final title = data['title'] ?? 'Unnamed';
    final domestic = (data['domestic'] as num? ?? 0).toInt();
    final saarc = (data['saarc'] as num? ?? 0).toInt();
    final tourist = (data['tourist'] as num? ?? 0).toInt();
    final timeSlots = List<String>.from(data['timeSlots'] ?? []);
    final imageUrl = data['imageUrl'] as String?;   // Firebase Storage URL
    final imagePath = data['image'] as String?;     // legacy local asset

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image header
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 130,
                fit: BoxFit.cover,
                placeholder: (_, __) => const SizedBox(
                    height: 130,
                    child: Center(child: CircularProgressIndicator())),
                errorWidget: (_, __, ___) => _imagePlaceholder(),
              ),
            )
          else if (imagePath != null && imagePath.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: 130,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagePlaceholder(),
              ),
            )
          else
            _imagePlaceholder(),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + action buttons
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: Colors.blueGrey, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditActivityPage(
                            docId: docId,
                            data: data,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _confirmDelete(context),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Pricing row
                Row(
                  children: [
                    _priceChip('Domestic', domestic, Colors.green.shade700),
                    const SizedBox(width: 6),
                    _priceChip('SAARC', saarc, Colors.blue.shade700),
                    const SizedBox(width: 6),
                    _priceChip('Tourist', tourist, Colors.orange.shade700),
                  ],
                ),

                if (timeSlots.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.access_time,
                          size: 13, color: Colors.black45),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          timeSlots.join('  •  '),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black54),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      child: Container(
        width: double.infinity,
        height: 100,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_outlined,
            size: 40, color: Colors.grey),
      ),
    );
  }

  Widget _priceChip(String label, int price, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 9, color: color, fontWeight: FontWeight.w600)),
            Text('Rs. $price',
                style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text('Remove "${data['title']}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              FirebaseFirestore.instance
                  .collection('activities')
                  .doc(docId)
                  .delete();
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
