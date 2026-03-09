import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'guide_slots_page.dart';
import 'manage_guides_page.dart';
import '../bookings/bookings_page.dart';
import '../categories/categories_page.dart';
import '../users/users_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 18) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Greeting Card =====
          _buildGreetingCard(),
          const SizedBox(height: 16),

          // ===== Live Metrics =====
          const _LiveMetrics(),
          const SizedBox(height: 24),

          // ===== Quick Actions =====
          _sectionLabel("Quick Actions"),
          const SizedBox(height: 10),
          _navRow(context, [
            _NavItem("Guide Assignments", const Color(0xFFE8F5E9), Icons.badge_outlined, const GuideSlotsPage()),
            _NavItem("Manage Guides", const Color(0xFFE0F7FA), Icons.people, const ManageGuidesPage()),
          ]),
          const SizedBox(height: 12),
          _navRow(context, [
            const _NavItem("Edit Flora and Fauna", Color(0xFFFFF8E1), Icons.category_outlined, AdminCategoriesPage()),
            null,
          ]),
          const SizedBox(height: 24),

          // ===== Recent Bookings =====
          _sectionLabel("Recent Bookings"),
          const SizedBox(height: 10),
          const _RecentBookings(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [Colors.green.shade100, Colors.green.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Admin",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEE, MMM d').format(DateTime.now()),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.black38),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.black87, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.black45,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _navRow(BuildContext context, List<_NavItem?> items) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          items[i] != null
              ? Expanded(child: _buildNavCard(context, items[i]!))
              : const Expanded(child: SizedBox()),
        ],
      ],
    );
  }

  Widget _buildNavCard(BuildContext context, _NavItem item) {
    return GestureDetector(
      onTap: item.page != null
          ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.page!))
          : null,
      child: Container(
        height: 85,
        decoration: BoxDecoration(
          color: item.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: Colors.black87, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String title;
  final Color color;
  final IconData icon;
  final Widget? page;
  const _NavItem(this.title, this.color, this.icon, this.page);
}

// ===== Recent Bookings =====
class _RecentBookings extends StatelessWidget {
  const _RecentBookings();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .orderBy('bookingTimestamp', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return const Text('No bookings yet.',
              style: TextStyle(color: Colors.black45));
        }
        return Column(
          children: docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            final activity = d['activity'] as String? ?? 'Activity';
            final visitor = d['visitorName'] as String? ?? 'Visitor';
            final date = d['date'] as String? ?? '';
            final status = d['status'] as String? ?? 'Pending';
            final isPaid = d['paymentStatus'] == 'Paid';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: isPaid
                        ? const Color(0xFFE8F5E9)
                        : Colors.orange.shade50,
                    child: Icon(
                      isPaid ? Icons.check_circle_outline : Icons.pending_outlined,
                      size: 18,
                      color: isPaid ? const Color(0xFF2E7D32) : Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(activity,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                        Text('$visitor  •  $date',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black45),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? const Color(0xFFE8F5E9)
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isPaid ? 'Paid' : status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isPaid ? const Color(0xFF2E7D32) : Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ===== Live Metrics =====
class _LiveMetrics extends StatelessWidget {
  const _LiveMetrics();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            label: "Total\nBookings",
            icon: Icons.calendar_month,
            colors: const [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
            count: (snap) => snap.docs.length,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookingsPage())),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricTile(
            label: "Active\nGuides",
            icon: Icons.badge_outlined,
            colors: const [Color(0xFFA5D6A7), Color(0xFF81C784)],
            stream: FirebaseFirestore.instance
                .collection('guides')
                .where('isActive', isEqualTo: true)
                .snapshots(),
            count: (snap) => snap.docs.length,
            showDot: true,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageGuidesPage())),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricTile(
            label: "Total\nUsers",
            icon: Icons.person_outline,
            colors: const [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            count: (snap) => snap.docs.length,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UsersPage())),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final Stream<QuerySnapshot> stream;
  final int Function(QuerySnapshot) count;
  final bool showDot;
  final VoidCallback? onTap;

  const _MetricTile({
    required this.label,
    required this.icon,
    required this.colors,
    required this.stream,
    required this.count,
    this.showDot = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snap) {
        final value = snap.hasData ? count(snap.data!).toString() : '—';
        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: 95,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: colors),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 13, color: Colors.black54),
                    if (showDot) ...[
                      const SizedBox(width: 3),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ],
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
