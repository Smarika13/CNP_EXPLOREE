import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'manage_faqs_page.dart';
import 'contact_requests_page.dart';
import 'booking_detail_page.dart';
import 'edit_rules_page.dart';
import 'publish_news_page.dart';
import 'guide_slots_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Map<String, dynamic> _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return {"text": "Good Morning"};
    } else if (hour < 18) {
      return {"text": "Good Afternoon"};
    } else {
      return {"text": "Good Evening"};
    }
  }

  @override
  Widget build(BuildContext context) {
    final greetingText = _getGreeting()["text"];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Greeting Card =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.green.shade100, Colors.green.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greetingText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Admin",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.black87, size: 28),
                )
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ===== Metric Cards =====
          Row(
            children: [
              const Expanded(
                child: MetricCard(
                  title: "Total Bookings",
                  value: "150",
                  colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                  icon: Icons.calendar_month,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  title: "Active Users",
                  value: "78",
                  colors: [Color(0xFFA5D6A7), Color(0xFF81C784)],
                  icon: Icons.people,
                  showActiveDot: true, // Green dot shown
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: MetricCard(
                  title: "New Users",
                  value: "12",
                  colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
                  icon: Icons.person_add,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Text(
            "Recent Bookings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._recentBookings(context),

          const SizedBox(height: 16),

          // ===== Guide Assignments Card =====
          _navCard(
            context,
            "Guide Assignments",
            const Color(0xFFE8F5E9),
            const GuideSlotsPage(),
            icon: Icons.badge_outlined,
          ),

          const SizedBox(height: 16),

          // ===== Admin Navigation Cards =====
          Row(
            children: [
              Expanded(
                child: _navCard(
                  context,
                  "Manage FAQs",
                  const Color(0xFFFFF3E0),
                  const ManageFAQsPage(),
                  icon: Icons.help_outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _navCard(
                  context,
                  "Contact Requests",
                  const Color(0xFFFFEBEE),
                  const ContactRequestsPage(),
                  icon: Icons.mail_outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _navCard(
                  context,
                  "Edit Rules",
                  const Color(0xFFE3F2FD),
                  const EditRulesPage(),
                  icon: Icons.edit,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ===== Second Row: Publish News & Edit Flora & Fauna =====
          Row(
            children: [
              Expanded(
                child: _navCard(
                  context,
                  "Publish News",
                  const Color(0xFFFFF9C4),
                  const PublishNewsPage(),
                  icon: Icons.newspaper,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1C4E9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.pets, color: Colors.black87),
                      SizedBox(width: 8),
                      Text(
                        "Edit Flora & Fauna",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Container()), // Empty space to balance row
            ],
          ),
        ],
      ),
    );
  }

  Widget _navCard(
      BuildContext context,
      String title,
      Color color,
      Widget page, {
        IconData? icon,
      }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        height: 90,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: Colors.black87),
            if (icon != null) const SizedBox(width: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _recentBookings(BuildContext context) {
    final List<Map<String, dynamic>> bookings = [
      {
        "user": "Sudikshya",
        "activity": "Jeep Safari",
        "bookedOn": "2026-03-05",
        "bookedFor": "2026-03-10",
        "time": "6–10 AM",
        "price": 3500,
        "image": "assets/images/jeep safari.jpg"
      },
      {
        "user": "Ramesh",
        "activity": "Elephant Safari",
        "bookedOn": "2026-03-08",
        "bookedFor": "2026-03-12",
        "time": "2–5 PM",
        "price": 5000,
        "image": "assets/images/elephant_safari.webp"
      },
      {
        "user": "Sita",
        "activity": "Bird Watching",
        "bookedOn": "2026-03-06",
        "bookedFor": "2026-03-11",
        "time": "6–10 AM",
        "price": 1200,
        "image": "assets/images/bird watching.jpeg"
      },
    ];

    final DateFormat formatter = DateFormat('MMM dd, yyyy');

    return bookings.map((b) {
      final bookedOn = formatter.format(DateTime.parse(b['bookedOn']));
      final bookedFor = formatter.format(DateTime.parse(b['bookedFor']));

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingDetailPage(
                booking: b,
                totalAmount: b['price'] as int,
              ),
            ),
          );
        },
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                b['image'] as String,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              "${b['activity']} - ${b['user']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Booked On: $bookedOn"),
                Text("Booked For: $bookedFor (${b['time']})"),
              ],
            ),
            trailing: Text(
              "Rs. ${b['price']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }).toList();
  }
}

// ===== Metric Card Widget =====
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final List<Color> colors;
  final IconData icon;
  final bool showActiveDot; // <-- new property

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.colors,
    required this.icon,
    this.showActiveDot = false, // default false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: colors),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(icon, size: 20, color: Colors.black87),
              ),
              if (showActiveDot)
                Positioned(
                  bottom: -2, // ✅ bottom-right
                  right: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
