import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../shared/services/guide_scheduler_service.dart';

class GuideSlotsPage extends StatefulWidget {
  const GuideSlotsPage({super.key});

  @override
  State<GuideSlotsPage> createState() => _GuideSlotsPageState();
}

class _GuideSlotsPageState extends State<GuideSlotsPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  DateTime _selectedDate = DateTime.now();

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_selectedDate);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text('Guide Assignments'),
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
            tooltip: 'Pick date',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date banner
          Container(
            width: double.infinity,
            color: const Color(0xFF2C5F2E),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.event, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _pickDate,
                  child: const Text('Change', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ),
              ],
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Color(0xFF1B4332),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFF1B4332),
                    tabs: [
                      Tab(text: 'Guide Slots'),
                      Tab(text: 'Pending'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _GuideSlotsList(dateStr: _dateStr),
                        _PendingBookingsList(db: _db),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab 1: Guide Slots ────────────────────────────────────────────────────────

class _GuideSlotsList extends StatelessWidget {
  final String dateStr;
  const _GuideSlotsList({required this.dateStr});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('guide_slots')
          .where('date', isEqualTo: dateStr)
          .orderBy('activityId')
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const Center(
            child: Text('No guide slots for this date.', style: TextStyle(color: Colors.grey)),
          );
        }

        // Group slots by activity
        final Map<String, List<QueryDocumentSnapshot>> grouped = {};
        for (final doc in snap.data!.docs) {
          final activity = doc['activityId'] as String;
          grouped.putIfAbsent(activity, () => []).add(doc);
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children: grouped.entries.map((entry) {
            return _ActivityGroup(activity: entry.key, slots: entry.value);
          }).toList(),
        );
      },
    );
  }
}

class _ActivityGroup extends StatelessWidget {
  final String activity;
  final List<QueryDocumentSnapshot> slots;

  const _ActivityGroup({required this.activity, required this.slots});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            activity,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF1B4332),
            ),
          ),
        ),
        ...slots.map((slot) => _SlotCard(slot: slot)),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _SlotCard extends StatelessWidget {
  final QueryDocumentSnapshot slot;
  const _SlotCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    final filled = slot['filledSeats'] as int;
    final max = slot['maxCapacity'] as int;
    final guideId = slot['guideId'] as String;
    final timeSlot = slot['timeSlot'] as String;
    final status = slot['status'] as String;
    final fillFraction = max > 0 ? filled / max : 0.0;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('guides').doc(guideId).get(),
      builder: (context, snap) {
        final guideName = snap.hasData ? (snap.data!['name'] ?? 'Unknown') : '...';
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Color(0xFF2C5F2E)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(guideName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: status == 'full' ? Colors.red[100] : Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status == 'full' ? 'Full' : 'Open',
                        style: TextStyle(
                          fontSize: 11,
                          color: status == 'full' ? Colors.red[800] : Colors.green[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$timeSlot  •  $filled/$max visitors',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fillFraction,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      fillFraction >= 1.0 ? Colors.red : const Color(0xFF4FBF26),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Tab 2: Pending bookings (no guide found) ──────────────────────────────────

class _PendingBookingsList extends StatelessWidget {
  final FirebaseFirestore db;
  const _PendingBookingsList({required this.db});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collection('bookings')
          .where('status', isEqualTo: 'Pending Guide')
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
                SizedBox(height: 12),
                Text('No pending assignments', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children: snap.data!.docs.map((doc) => _PendingCard(booking: doc)).toList(),
        );
      },
    );
  }
}

class _PendingCard extends StatelessWidget {
  final QueryDocumentSnapshot booking;
  const _PendingCard({required this.booking});

  void _showAssignDialog(BuildContext context) {
    final data = booking.data() as Map<String, dynamic>;
    final activity = data['pendingActivity'] as String? ?? '';
    final date = data['date'] as String? ?? '';
    final timeSlot = data['time'] as String? ?? '';
    final counts = data['visitorCounts'] as Map<String, dynamic>? ?? {};
    final groupSize = ((counts['domestic'] ?? 0) as int) +
        ((counts['saarc'] ?? 0) as int) +
        ((counts['tourist'] ?? 0) as int);

    String? selectedGuideId;
    String? selectedGuideName;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Assign Guide: $activity'),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('guides')
                  .where('isActive', isEqualTo: true)
                  .where('specializations', arrayContains: activity)
                  .get(),
              builder: (_, snap) {
                if (!snap.hasData) return const CircularProgressIndicator();
                final guides = snap.data!.docs;
                if (guides.isEmpty) {
                  return const Text('No guides available for this activity.');
                }
                return DropdownButtonFormField<String>(
                  hint: const Text('Select a guide'),
                  value: selectedGuideId,
                  items: guides.map((g) {
                    return DropdownMenuItem(
                      value: g.id,
                      child: Text(g['name'] as String),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setDialogState(() {
                      selectedGuideId = val;
                      selectedGuideName = guides
                          .firstWhere((g) => g.id == val)['name'] as String;
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B4332)),
              onPressed: selectedGuideId == null
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                      await GuideSchedulerService().manuallyAssignGuide(
                        bookingId: booking.id,
                        activity: activity,
                        date: date,
                        timeSlot: timeSlot,
                        guideId: selectedGuideId!,
                        groupSize: groupSize,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$selectedGuideName assigned to $activity'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
              child: const Text('Assign', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = booking.data() as Map<String, dynamic>;
    final activities = (data['activities'] as List<dynamic>?)?.join(', ') ?? '';
    final date = data['date'] as String? ?? '';
    final time = data['time'] as String? ?? '';
    final userName = data['userName'] as String? ?? 'Guest';
    final pendingActivity = data['pendingActivity'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.orange, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () => _showAssignDialog(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4332),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  child: const Text('Assign Guide', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Activities: $activities', style: const TextStyle(fontSize: 12)),
            Text('Date: $date  •  $time', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              'Needs guide for: $pendingActivity',
              style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
