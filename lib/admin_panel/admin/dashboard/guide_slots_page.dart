import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class GuideSlotsPage extends StatefulWidget {
  const GuideSlotsPage({super.key});

  @override
  State<GuideSlotsPage> createState() => _GuideSlotsPageState();
}

class _GuideSlotsPageState extends State<GuideSlotsPage> {
  DateTime _selectedDate = DateTime.now();

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_selectedDate);

  @override
  void initState() {
    super.initState();
    _repairOverbookedSlots();
  }

  /// Scans the entire guide_slots collection and caps any filledSeats > maxCapacity.
  Future<void> _repairOverbookedSlots() async {
    final snap = await FirebaseFirestore.instance.collection('guide_slots').get();
    final batch = FirebaseFirestore.instance.batch();
    bool hasFixes = false;

    for (final doc in snap.docs) {
      final data = doc.data();
      final filled = data['filledSeats'] as int? ?? 0;
      final max    = data['maxCapacity'] as int? ?? 1;
      if (filled > max) {
        batch.update(doc.reference, {
          'filledSeats': max,
          'status': 'full',
        });
        hasFixes = true;
      }
    }

    if (hasFixes) await batch.commit();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
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
          Expanded(child: _GuideSlotsList(dateStr: _dateStr)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GuideSlotsList extends StatelessWidget {
  final String dateStr;
  const _GuideSlotsList({required this.dateStr});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('guide_slots')
          .where('date', isEqualTo: dateStr)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)));
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_off_outlined, size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text('No slots for this date.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        // Sort client-side by activityId to avoid composite index requirement
        final docs = [...snap.data!.docs]
          ..sort((a, b) {
            final aId = (a.data() as Map)['activityId'] as String? ?? '';
            final bId = (b.data() as Map)['activityId'] as String? ?? '';
            return aId.compareTo(bId);
          });

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          itemCount: docs.length,
          itemBuilder: (context, i) => _SlotCard(slot: docs[i]),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SlotCard extends StatelessWidget {
  final QueryDocumentSnapshot slot;
  const _SlotCard({required this.slot});

  Color _capColor(double fraction) {
    if (fraction >= 1.0) return Colors.red;
    if (fraction >= 0.75) return Colors.orange;
    return const Color(0xFF2E7D32);
  }

  // Activity → icon mapping
  IconData _activityIcon(String activity) {
    switch (activity.toLowerCase()) {
      case 'jeep safari':            return Icons.directions_car;
      case 'canoe ride':             return Icons.rowing;
      case 'bird watching':          return Icons.visibility;
      case 'elephant safari':        return Icons.pets;
      case 'jungle walk':            return Icons.hiking;
      case 'tharu cultural program': return Icons.theater_comedy;
      case 'tharu museum':           return Icons.museum;
      default:                       return Icons.local_activity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data      = slot.data() as Map<String, dynamic>;
    final activity  = data['activityId'] as String? ?? '—';
    final filled    = data['filledSeats'] as int? ?? 0;
    final max       = data['maxCapacity'] as int? ?? 1;
    final timeSlot  = data['timeSlot'] as String? ?? '—';
    final slotType  = data['slotType'] as String? ?? 'guide';
    final guideId   = data['guideId'] as String? ?? '';
    final isFull    = (data['status'] as String? ?? '') == 'full';
    final fraction  = max > 0 ? (filled / max).clamp(0.0, 1.0) : 0.0;
    final isOverbooked = filled > max;
    final color     = isOverbooked ? Colors.red : _capColor(fraction);

    // Decide header label and resource tag
    String resourceLabel;
    Color  headerColor;
    switch (slotType) {
      case 'venue':
        resourceLabel = 'Venue Seating';
        headerColor   = const Color(0xFF4A148C);
        break;
      case 'resource':
        resourceLabel = 'No Guide · Elephant';
        headerColor   = const Color(0xFF4E342E);
        break;
      default:
        resourceLabel = 'Guide Assigned';
        headerColor   = const Color(0xFF1B4332);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: activity + time ──────────────────────────────────────
          Container(
            width: double.infinity,
            color: headerColor,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(_activityIcon(activity), color: Colors.white70, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    activity,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    resourceLabel,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.access_time, color: Colors.white54, size: 13),
                const SizedBox(width: 4),
                Text(timeSlot,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Guide / resource row
                if (slotType == 'guide')
                  _GuideRow(guideId: guideId, maxCapacity: max, isFull: isFull)
                else
                  _NoGuideRow(slotType: slotType, maxCapacity: max, isFull: isFull),

                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Overbooked warning (legacy data guard)
                if (isOverbooked)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red.shade700),
                        const SizedBox(width: 6),
                        Text(
                          'Overbooked: $filled booked, max is $max',
                          style: TextStyle(fontSize: 11, color: Colors.red.shade700, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),

                // Capacity numbers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'VISITORS',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.8),
                    ),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: '$filled',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: color),
                        ),
                        TextSpan(
                          text: ' / $max',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade500),
                        ),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Seat dots
                Row(
                  children: List.generate(
                    max,
                    (i) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 2),
                        height: 5,
                        decoration: BoxDecoration(
                          color: i < filled ? color : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Remaining seats
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    isFull
                        ? 'No seats remaining'
                        : '${max - filled} seat${max - filled == 1 ? '' : 's'} remaining',
                    style: TextStyle(
                        fontSize: 11,
                        color: isFull
                            ? Colors.red.shade400
                            : Colors.grey.shade500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Guide row — fetches guide name async
// ─────────────────────────────────────────────────────────────────────────────

class _GuideRow extends StatelessWidget {
  final String guideId;
  final int maxCapacity;
  final bool isFull;
  const _GuideRow(
      {required this.guideId,
      required this.maxCapacity,
      required this.isFull});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('guides').doc(guideId).get(),
      builder: (context, snap) {
        final guideName = snap.hasData
            ? ((snap.data!.data() as Map?)?['name'] as String? ?? 'Unknown')
            : '…';
        final initials = guideName == '…'
            ? '?'
            : guideName
                .trim()
                .split(' ')
                .take(2)
                .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
                .join();

        return Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFE8F5E9),
              child: Text(initials,
                  style: const TextStyle(
                      color: Color(0xFF1B4332),
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(guideName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text('Max capacity: $maxCapacity visitors',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            _StatusBadge(isFull: isFull),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// No-guide row (Elephant Safari / Venue)
// ─────────────────────────────────────────────────────────────────────────────

class _NoGuideRow extends StatelessWidget {
  final String slotType;
  final int maxCapacity;
  final bool isFull;
  const _NoGuideRow(
      {required this.slotType,
      required this.maxCapacity,
      required this.isFull});

  @override
  Widget build(BuildContext context) {
    final isVenue    = slotType == 'venue';
    final bgColor    = isVenue ? const Color(0xFFEDE7F6) : const Color(0xFFEFEBE9);
    final iconColor  = isVenue ? const Color(0xFF4A148C) : const Color(0xFF4E342E);
    final label      = isVenue ? 'Open Venue' : 'No Guide Required';
    final sublabel   = isVenue
        ? 'Max $maxCapacity seats'
        : 'Max $maxCapacity visitors per elephant';

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: bgColor,
          child: Icon(
            isVenue ? Icons.chair_outlined : Icons.pets,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: iconColor)),
              const SizedBox(height: 2),
              Text(sublabel,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ),
        _StatusBadge(isFull: isFull),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared status badge
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isFull;
  const _StatusBadge({required this.isFull});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isFull ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isFull ? Colors.red.shade200 : Colors.green.shade200),
      ),
      child: Text(
        isFull ? 'Full' : 'Open',
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isFull ? Colors.red.shade700 : Colors.green.shade700),
      ),
    );
  }
}
