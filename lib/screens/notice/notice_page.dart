import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';

class NoticePage extends StatelessWidget {
  const NoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B5E20);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F5),
        body: Column(
          children: [
            const SizedBox(height: 16),

            // Top TabBar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const TabBar(
                labelColor: primaryGreen,
                unselectedLabelColor: Colors.black54,
                indicatorColor: primaryGreen,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(icon: Icon(Icons.notifications), text: "Notifications"),
                  Tab(icon: Icon(Icons.newspaper), text: "News"),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Tab content
            Expanded(
              child: TabBarView(
                children: [
                  // --- 1. Notifications Tab (Still Static/Dummy) ---
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.notifications, color: primaryGreen),
                          title: Text("Booking Confirmed"),
                          subtitle: Text("Your Jeep Safari booking is confirmed."),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.notifications, color: primaryGreen),
                          title: Text("Safari Reminder"),
                          subtitle: Text("Elephant Safari scheduled for tomorrow."),
                        ),
                      ),
                    ],
                  ),

                  // --- 2. News Tab (NOW DYNAMIC FROM FIREBASE) ---
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('news') // Must match your Admin collection name
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(child: Text("Error loading news"));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final newsDocs = snapshot.data!.docs;

                      if (newsDocs.isEmpty) {
                        return const Center(
                          child: Text("No news updates at the moment."),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: newsDocs.length,
                        itemBuilder: (context, index) {
                          final data = newsDocs[index].data() as Map<String, dynamic>;
                          
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.newspaper, color: primaryGreen),
                              title: Text(data['title'] ?? 'Untitled News'),
                              subtitle: Text(data['subtitle'] ?? data['description'] ?? ''),
                              // Optional: You can add a timestamp display here too
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}