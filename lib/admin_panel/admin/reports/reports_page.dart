import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  ReportsPage({super.key});

  // ===== Sample Data =====
  final int totalBookingsToday = 12;
  final int totalBookingsWeek = 45;
  final int totalBookingsMonth = 120;

  final Map<String, int> bookingsPerActivity = {
    "Jeep Safari": 40,
    "Bird Watching": 25,
    "Elephant Safari": 30,
    "Jungle Walk": 15,
    "Canoe Ride": 10,
    "Tharu Cultural Program": 20,
    "Tharu Museum": 10,
  };

  final Map<String, int> bookingsPerCategory = {
    "Domestic": 80,
    "SAARC": 50,
    "Tourist": 40,
  };

  final int totalUsers = 150;
  final int activeUsers = 120;
  final int newRegistrations = 10;

  final double cardHeight = 100; // standard card height
  final double cardBorderRadius = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Booking Stats =====
              const Text("Booking Stats",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildStatRowCard(
                      "Today", totalBookingsToday.toString(), Colors.green, Icons.today),
                  _buildStatRowCard("This Week", totalBookingsWeek.toString(),
                      Colors.orange, Icons.date_range),
                  _buildStatRowCard(
                      "This Month", totalBookingsMonth.toString(), Colors.blue,
                      Icons.calendar_month),
                ],
              ),
              const SizedBox(height: 24),

              // ===== Bookings per Activity =====
              const Text("Bookings per Activity",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Column(
                children: bookingsPerActivity.entries.map((e) {
                  double percent = e.value /
                      (bookingsPerActivity.values
                          .reduce((a, b) => a > b ? a : b));
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _buildActivityProgressCard(e.key, e.value, percent),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ===== Bookings per Category =====
              const Text("Bookings per Category",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: bookingsPerCategory.entries.map((e) {
                  IconData iconData;
                  switch (e.key) {
                    case "Domestic":
                      iconData = Icons.home;
                      break;
                    case "SAARC":
                      iconData = Icons.public;
                      break;
                    case "Tourist":
                    default:
                      iconData = Icons.airplanemode_active;
                      break;
                  }

                  return _buildStatRowCard(e.key, "${e.value}", Colors.teal,
                      iconData);
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ===== User Stats =====
              const Text("User Stats",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildStatRowCard(
                      "Total Users", totalUsers.toString(), Colors.blue, Icons.group),
                  _buildStatRowCard(
                      "Active Users", activeUsers.toString(), Colors.green, Icons.person),
                  _buildStatRowCard("New Registrations", newRegistrations.toString(),
                      Colors.orange, Icons.person_add),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== Stat Card with icon + label + value in a row =====
  Widget _buildStatRowCard(String label, String value, Color color, IconData iconData) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 180),
      child: Container(
        height: cardHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(cardBorderRadius),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Icon(iconData, color: color, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "$label ($value)",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ===== Activity Progress Card =====
  Widget _buildActivityProgressCard(String activity, int value, double progress) {
    return Container(
      height: cardHeight * 0.7,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$activity ($value)",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            color: Colors.green,
            backgroundColor: Colors.grey.shade300,
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}
