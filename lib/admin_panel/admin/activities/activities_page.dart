import 'package:flutter/material.dart';
import 'add_activity_page.dart';
import 'edit_activity_page.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  // Dynamic list of activities
  List<Map<String, dynamic>> activities = [
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
      "timeSlots": [
        "10:00 AM - 10:30 AM",
        "10:30 AM - 11:00 AM",
        "11:00 AM - 11:30 AM",
      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ActivityCard(
            activity: activity,
            onEdit: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditActivityPage(
                    name: activity["title"],
                    domestic: activity["domestic"],
                    saarc: activity["saarc"],
                    tourist: activity["tourist"],
                    timeSlots: List<String>.from(activity["timeSlots"]),
                  ),
                ),
              );

              if (updated != null) {
                setState(() {
                  activities[index] = updated;
                });
              }
            },
            onDelete: () {
              setState(() {
                activities.removeAt(index);
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4FBF26),
        child: const Icon(Icons.add),
        onPressed: () async {
          final newActivity = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddActivityPage()),
          );

          if (newActivity != null) {
            setState(() {
              activities.add(newActivity);
            });
          }
        },
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  final Map<String, dynamic> activity;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              activity["image"],
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              activity["title"],
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
