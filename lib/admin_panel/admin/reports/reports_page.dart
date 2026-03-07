import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../bookings/bookings_page.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .orderBy('bookingTimestamp', descending: true)
          .snapshots(),
      builder: (context, bookingSnap) {
            final loading =
                bookingSnap.connectionState == ConnectionState.waiting;

            if (loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final bookings = bookingSnap.data?.docs ?? [];

            // Date ranges
            final now = DateTime.now();
            final todayStart = DateTime(now.year, now.month, now.day);
            final weekStart = now.subtract(const Duration(days: 7));
            final monthStart = now.subtract(const Duration(days: 30));

            // Booking trend counts
            int todayCount = 0, weekCount = 0, monthCount = 0;
            int totalRevenue = 0;
            int domVisitors = 0, saarcVisitors = 0, touristVisitors = 0;
            final Map<String, int> activityCount = {};

            for (final doc in bookings) {
              final data = doc.data() as Map<String, dynamic>;
              final ts = data['bookingTimestamp'] as Timestamp?;
              final amount = (data['totalAmount'] as num? ?? 0).toInt();
              totalRevenue += amount;

              // Visitor counts (nested map)
              final vc = data['visitorCounts'] as Map?;
              if (vc != null) {
                domVisitors += (vc['domestic'] as num? ?? 0).toInt();
                saarcVisitors += (vc['saarc'] as num? ?? 0).toInt();
                touristVisitors += (vc['tourist'] as num? ?? 0).toInt();
              }

              // Activity (single string field)
              final activity = data['activity'] as String?;
              if (activity != null && activity.isNotEmpty) {
                activityCount[activity] = (activityCount[activity] ?? 0) + 1;
              }
              // Also support legacy 'activities' array field
              final activitiesList = data['activities'] as List?;
              if (activitiesList != null) {
                for (final a in activitiesList) {
                  final name = a.toString();
                  activityCount[name] = (activityCount[name] ?? 0) + 1;
                }
              }

              if (ts != null) {
                final dt = ts.toDate();
                if (dt.isAfter(todayStart)) todayCount++;
                if (dt.isAfter(weekStart)) weekCount++;
                if (dt.isAfter(monthStart)) monthCount++;
              }
            }

            final sortedActivities = activityCount.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            final maxActivity =
                sortedActivities.isEmpty ? 1 : sortedActivities.first.value;

            final primary = Theme.of(context).colorScheme.primary;
            final fmt = NumberFormat('#,##0');

            return Scaffold(
              backgroundColor: const Color(0xFFF4F6F5),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Booking Trends ──
                    _label('BOOKING TRENDS'),
                    const SizedBox(height: 10),
                    Row(children: [
                      _trendCard(context, 'Today', todayCount,
                          Icons.today, Colors.teal,
                          startDate: todayStart,
                          endDate: todayStart.add(const Duration(days: 1))),
                      const SizedBox(width: 10),
                      _trendCard(context, 'This Week', weekCount,
                          Icons.date_range, Colors.orange,
                          startDate: weekStart),
                      const SizedBox(width: 10),
                      _trendCard(context, 'This Month', monthCount,
                          Icons.calendar_month, Colors.blue,
                          startDate: monthStart),
                    ]),
                    const SizedBox(height: 20),

                    // ── Revenue ──
                    _label('TOTAL REVENUE'),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const AdminBookingsPage())),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Revenue',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54)),
                                  Text(
                                    'Rs. ${fmt.format(totalRevenue)}',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: primary),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                color: primary.withOpacity(0.5)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Visitor Types ──
                    _label('VISITOR TYPES'),
                    const SizedBox(height: 10),
                    Row(children: [
                      _visitorCard('Domestic', domVisitors,
                          Icons.home_outlined, Colors.green.shade700),
                      const SizedBox(width: 10),
                      _visitorCard('SAARC', saarcVisitors,
                          Icons.public, Colors.blue.shade700),
                      const SizedBox(width: 10),
                      _visitorCard('Foreign', touristVisitors,
                          Icons.airplanemode_active,
                          Colors.orange.shade700),
                    ]),
                    const SizedBox(height: 20),

                    // ── Bookings per Activity ──
                    _label('BOOKINGS PER ACTIVITY'),
                    const SizedBox(height: 10),
                    if (sortedActivities.isEmpty)
                      const Text('No data yet.',
                          style: TextStyle(color: Colors.grey))
                    else
                      ...sortedActivities.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _activityBar(
                                context, e.key, e.value, maxActivity, primary),
                          )),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
      },
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(text,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black45,
                letterSpacing: 1.2)),
      );

  Widget _trendCard(BuildContext context, String label, int value,
      IconData icon, Color color,
      {DateTime? startDate, DateTime? endDate}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AdminBookingsPage(
                      startDate: startDate,
                      endDate: endDate,
                      dateLabel: label,
                    ))),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 4),
              Text(value.toString(),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 10, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _visitorCard(
      String label, int count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(count.toString(),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 10, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _activityBar(BuildContext context, String name, int count,
      int max, Color primary) {
    final pct = max == 0 ? 0.0 : count / max;
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => AdminBookingsPage(activityFilter: name))),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                Text('$count',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 7,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
