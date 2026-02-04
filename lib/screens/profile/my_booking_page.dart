import 'package:flutter/material.dart';

class MyBookingPage extends StatelessWidget {
  const MyBookingPage({super.key});

  // Sample data for bookings (you can replace this with real data later)
  final List<Map<String, String>> bookings = const [
    {
      "activity": "Jeep Safari",
      "date": "2026-02-05",
      "time": "6–10 AM",
      "status": "Confirmed",
    },
    {
      "activity": "Elephant Safari",
      "date": "2026-02-06",
      "time": "2–5 PM",
      "status": "Pending",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Booking"),
        backgroundColor: const Color(0xFF4FBF26),
        centerTitle: true,
      ),
      body: bookings.isEmpty
          ? const Center(
        child: Text(
          "No bookings yet.",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                booking['activity']!,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                  "${booking['date']} | ${booking['time']}\nStatus: ${booking['status']}"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Here you can navigate to booking details page if needed
              },
            ),
          );
        },
      ),
    );
  }
}
