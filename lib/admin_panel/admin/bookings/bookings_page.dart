import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminBookingsPage extends StatelessWidget {
  const AdminBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text("Admin: Verify Bookings", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4FBF26),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .orderBy('bookingTimestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No bookings found."));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              
              // This line looks for the new userName field you just added
              final String displayName = data['userName'] ?? "ID: ${data['userId']?.toString().substring(0, 8)}";
              final String status = data['status'] ?? "Pending";
              final List activities = data['activities'] ?? [];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Activities: ${activities.join(', ')}\nStatus: $status"),
                  isThreeLine: true,
                  trailing: Icon(
                    status == "Confirmed" ? Icons.check_circle : Icons.pending,
                    color: status == "Confirmed" ? Colors.green : Colors.orange,
                  ),
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => AdminDetailView(docId: docs[index].id, data: data))
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Detailed View for Admin to Approve/Reject
class AdminDetailView extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  const AdminDetailView({super.key, required this.docId, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Details"), backgroundColor: const Color(0xFF4FBF26)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Customer: ${data['userName'] ?? 'N/A'}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Text("Date: ${data['date']}"),
            Text("Time: ${data['time']}"),
            Text("Total: Rs. ${data['totalAmount']}"),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
              onPressed: () => FirebaseFirestore.instance.collection('bookings').doc(docId).update({'status': 'Confirmed'}).then((_) => Navigator.pop(context)),
              child: const Text("Approve Booking", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, minimumSize: const Size(double.infinity, 50)),
              onPressed: () => FirebaseFirestore.instance.collection('bookings').doc(docId).update({'status': 'Cancelled'}).then((_) => Navigator.pop(context)),
              child: const Text("Reject Booking"),
            ),
          ],
        ),
      ),
    );
  }
}