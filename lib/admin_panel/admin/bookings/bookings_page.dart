import 'package:flutter/material.dart';

// Booking data with price per person
final List<Map<String, dynamic>> bookings = [
  {
    "activity": "Jeep Safari",
    "user": "Sudikshya",
    "date": "2026-02-10",
    "time": "6–10 AM",
    "bookedOn": "2026-02-01", // added bookedOn
    "bookedFor": "2026-02-10", // added bookedFor
    "domestic": 1,
    "saarc": 0,
    "tourist": 0,
    "pricePerPerson": {"domestic": 500, "saarc": 1500, "tourist": 3500},
  },
  {
    "activity": "Elephant Safari",
    "user": "Ramesh",
    "date": "2026-02-12",
    "time": "2–5 PM",
    "bookedOn": "2026-02-03",
    "bookedFor": "2026-02-12",
    "domestic": 1,
    "saarc": 1,
    "tourist": 0,
    "pricePerPerson": {"domestic": 1650, "saarc": 4000, "tourist": 5000},
  },
  {
    "activity": "Bird Watching",
    "user": "Sita",
    "date": "2026-02-11",
    "time": "6–10 AM",
    "bookedOn": "2026-02-05",
    "bookedFor": "2026-02-11",
    "domestic": 0,
    "saarc": 1,
    "tourist": 1,
    "pricePerPerson": {"domestic": 3000, "saarc": 5500, "tourist": 6500},
  },
];

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sort bookings by date
    bookings.sort((a, b) => DateTime.parse(a['date'])
        .compareTo(DateTime.parse(b['date'])));

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];

          // Calculate total dynamically
          int totalAmount = booking['domestic'] * booking['pricePerPerson']['domestic'] +
              booking['saarc'] * booking['pricePerPerson']['saarc'] +
              booking['tourist'] * booking['pricePerPerson']['tourist'];

          return BookingCard(
            booking: booking,
            totalAmount: totalAmount,
          );
        },
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final int totalAmount;

  const BookingCard({super.key, required this.booking, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['activity'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text("${booking['user']} • ${booking['time']}"),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Rs. $totalAmount",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.visibility, color: Color(0xFF4FBF26)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingDetailPage(
                          booking: booking, totalAmount: totalAmount),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BookingDetailPage extends StatelessWidget {
  final Map<String, dynamic> booking;
  final int totalAmount;

  const BookingDetailPage({super.key, required this.booking, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: const Color(0xFF4FBF26),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow("Activity", booking['activity']),
              _infoRow("User", booking['user']),
              _infoRow("Booked On", booking['bookedOn']),
              _infoRow("Booked For", "${booking['bookedFor']} (${booking['time']})"),
              const SizedBox(height: 12),
              const Text(
                "Booking Type & Visitors",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              _visitorRow(
                  "Domestic", booking['domestic'], booking['pricePerPerson']['domestic']),
              _visitorRow(
                  "SAARC", booking['saarc'], booking['pricePerPerson']['saarc']),
              _visitorRow(
                  "Tourist", booking['tourist'], booking['pricePerPerson']['tourist']),
              const Divider(height: 20, thickness: 1),
              _infoRow("Total Amount", "Rs. $totalAmount"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _visitorRow(String type, int count, int pricePerPerson) {
    if (count == 0) return const SizedBox.shrink();
    int total = count * pricePerPerson;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$type Visitors (x$count)"),
          Text("Rs. $total"),
        ],
      ),
    );
  }
}
