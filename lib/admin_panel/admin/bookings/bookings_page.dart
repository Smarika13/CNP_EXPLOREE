import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/app_theme.dart';

class AdminBookingsPage extends StatefulWidget {
  final String? activityFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? dateLabel;
  const AdminBookingsPage({
    super.key,
    this.activityFilter,
    this.startDate,
    this.endDate,
    this.dateLabel,
  });

  @override
  State<AdminBookingsPage> createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends State<AdminBookingsPage> {
  bool _cleaning = false;

  Future<void> _deleteMultiActivityBookings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Multi-Activity Bookings'),
        content: const Text(
            'This will permanently delete all bookings that contain more than one activity. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _cleaning = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('bookings')
          .get();

      final toDelete = snap.docs.where((doc) {
        final acts = doc.data()['activities'] as List?;
        return acts != null && acts.length > 1;
      }).toList();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in toDelete) {
        batch.delete(doc.reference);
      }

      // Also delete orphaned guide_slots linked to these bookings
      for (final doc in toDelete) {
        final slotsSnap = await FirebaseFirestore.instance
            .collection('guide_slots')
            .where('bookingIds', arrayContains: doc.id)
            .get();
        for (final slotDoc in slotsSnap.docs) {
          batch.delete(slotDoc.reference);
        }
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted ${toDelete.length} multi-activity booking(s) and their slots.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _cleaning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.dateLabel ?? widget.activityFilter ?? "Bookings";
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          if (widget.activityFilter == null &&
              widget.startDate == null &&
              widget.endDate == null)
            _cleaning
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    tooltip: 'Delete multi-activity bookings',
                    icon: const Icon(Icons.cleaning_services_outlined),
                    onPressed: _deleteMultiActivityBookings,
                  ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .orderBy('bookingTimestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allDocs = snapshot.data!.docs;
          var docs = widget.activityFilter == null
              ? allDocs
              : allDocs.where((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  final act = d['activity'] as String? ?? '';
                  final acts = d['activities'] as List? ?? [];
                  return act == widget.activityFilter ||
                      acts.any((a) => a.toString() == widget.activityFilter);
                }).toList();

          // Date filter
          if (widget.startDate != null || widget.endDate != null) {
            docs = docs.where((doc) {
              final d = doc.data() as Map<String, dynamic>;
              final ts = d['bookingTimestamp'] as Timestamp?;
              if (ts == null) return false;
              final dt = ts.toDate();
              if (widget.startDate != null && dt.isBefore(widget.startDate!)) return false;
              if (widget.endDate != null && dt.isAfter(widget.endDate!)) return false;
              return true;
            }).toList();
          }

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.book_online_outlined,
                      size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    widget.activityFilter != null
                        ? "No bookings for ${widget.activityFilter}."
                        : "No bookings yet.",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return _BookingCard(docId: docs[index].id, data: data);
            },
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  const _BookingCard({required this.docId, required this.data});

  @override
  Widget build(BuildContext context) {
    final String name = data['userName'] ?? "Unknown";
    final activity = data['activity'] as String?;
    final List activitiesList = data['activities'] ?? [];
    final String activityDisplay = activity != null && activity.isNotEmpty
        ? activity
        : activitiesList.join(', ');
    final String date = data['date'] ?? '—';
    final String time = data['timeSlot'] ?? data['time'] ?? '—';
    final int total = (data['totalAmount'] as num? ?? 0).toInt();
    final int groupSize =
        (data['groupSize'] as num? ?? data['visitors'] as num? ?? 0).toInt();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AdminDetailView(docId: docId, data: data)),
      ),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                activityDisplay.isNotEmpty ? activityDisplay : '—',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style:
                    const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 12, color: Colors.black45),
                  const SizedBox(width: 4),
                  Text(date,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                  const SizedBox(width: 12),
                  const Icon(Icons.access_time,
                      size: 12, color: Colors.black45),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(time,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ),
                  if (groupSize > 0) ...[
                    const Icon(Icons.people,
                        size: 12, color: Colors.black45),
                    const SizedBox(width: 4),
                    Text("$groupSize",
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    "Rs. $total",
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4332)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== Detail View =====
class AdminDetailView extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  const AdminDetailView(
      {super.key, required this.docId, required this.data});

  @override
  Widget build(BuildContext context) {
    final String name = data['userName'] ?? 'N/A';
    final activity = data['activity'] as String?;
    final List activitiesList = data['activities'] ?? [];
    final String activityDisplay = activity != null && activity.isNotEmpty
        ? activity
        : activitiesList.join(', ');
    final String date = data['date'] ?? '—';
    final String time = data['timeSlot'] ?? data['time'] ?? '—';
    final int total = (data['totalAmount'] as num? ?? 0).toInt();
    final int groupSize =
        (data['groupSize'] as num? ?? data['visitors'] as num? ?? 0).toInt();
    final Timestamp? ts = data['bookingTimestamp'];
    final String bookedOn = ts != null
        ? DateFormat('MMM d, yyyy • h:mm a').format(ts.toDate())
        : '—';

    // Visitor counts
    final vc = data['visitorCounts'] as Map?;
    final int domestic = (vc?['domestic'] as num? ?? 0).toInt();
    final int saarc = (vc?['saarc'] as num? ?? 0).toInt();
    final int tourist = (vc?['tourist'] as num? ?? 0).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _row(Icons.person, "Customer", name),
                  _divider(),
                  _row(Icons.local_activity, "Activity",
                      activityDisplay.isNotEmpty ? activityDisplay : '—'),
                  _divider(),
                  _row(Icons.calendar_today, "Date", date),
                  _divider(),
                  _row(Icons.access_time, "Time Slot", time),
                  if (groupSize > 0) ...[
                    _divider(),
                    _row(Icons.people, "Group Size", "$groupSize"),
                  ],
                  if (domestic > 0 || saarc > 0 || tourist > 0) ...[
                    _divider(),
                    _row(Icons.groups, "Visitors",
                        [
                          if (domestic > 0) 'Domestic: $domestic',
                          if (saarc > 0) 'SAARC: $saarc',
                          if (tourist > 0) 'Foreign: $tourist',
                        ].join('  •  ')),
                  ],
                  _divider(),
                  _row(Icons.currency_rupee, "Total Amount",
                      "Rs. $total"),
                  _divider(),
                  _row(Icons.schedule, "Booked On", bookedOn),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: kSeedColor),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1);
}
