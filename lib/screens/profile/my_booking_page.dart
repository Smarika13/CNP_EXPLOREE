import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyBookingPage extends StatefulWidget {
  const MyBookingPage({super.key});

  @override
  State<MyBookingPage> createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage> {
  // Logic to handle deletion/cancellation of a booking
  void _confirmDeletion(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Booking?"),
        content: const Text("Are you sure you want to remove this activity from your schedule?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('bookings').doc(docId).delete();
              if (mounted) Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Booking cancelled successfully")),
              );
            },
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Booking"),
        backgroundColor: const Color(0xFF4FBF26), // Your custom green
        centerTitle: true,
      ),
      // We use StreamBuilder to listen to the 'bookings' collection in real-time
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .orderBy('bookingDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // 1. Check for errors
          if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
          
          // 2. Show loader while fetching data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // 3. Handle Empty State
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No bookings yet.",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            );
          }

          // 4. Build the list with real data
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              // Formatting the list of activities into a single string
              final List<dynamic> activityList = data['activities'] ?? [];
              final String activityNames = activityList.join(', ');

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    activityNames,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Park: ${data['parkName']}\nStatus: ${data['status']}",
                    style: const TextStyle(height: 1.5),
                  ),
                  // Added a delete icon so the user can actually interact with their data
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _confirmDeletion(context, doc.id),
                  ),
                  onTap: () {
                    // Optional: Navigate to a detailed view
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}