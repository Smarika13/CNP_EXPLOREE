import 'package:cloud_firestore/cloud_firestore.dart';

class GuideSchedulerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Max visitors a single guide can handle per activity
  static const Map<String, int> guideCapacity = {
    'Jeep Safari': 10,
    'Canoe Ride': 10,
    'Elephant Safari': 4,
    'Bird Watching': 6,
    'Jungle Walk': 5,
  };

  // These activities need no guide — just venue seats
  static const Set<String> venueActivities = {
    'Tharu Cultural Program',
    'Tharu Museum',
  };

  /// Called after a booking is saved to Firestore.
  /// Automatically assigns guides for every guide-required activity.
  Future<void> assignGuidesForBooking({
    required String bookingId,
    required List<String> activities,
    required String date,
    required String timeSlot,
    required int groupSize,
  }) async {
    final Map<String, dynamic> guideAssignments = {};
    final Map<String, dynamic> slotAssignments = {};
    String? pendingActivity;

    for (final activity in activities) {
      if (venueActivities.contains(activity)) continue;
      if (!guideCapacity.containsKey(activity)) continue;

      final maxCap = guideCapacity[activity]!;

      // Step 1: find an existing open slot with enough remaining seats
      final openSlot = await _findOpenSlot(activity, date, timeSlot, groupSize, maxCap);

      if (openSlot != null) {
        await _addToSlot(openSlot.id, bookingId, groupSize);
        guideAssignments[activity] = openSlot['guideId'];
        slotAssignments[activity] = openSlot.id;
      } else {
        // Step 2: no open slot — find a free guide and create a new slot
        final guide = await _findAvailableGuide(activity, date, timeSlot);

        if (guide != null) {
          final slotId = await _createSlot(
            activity: activity,
            date: date,
            timeSlot: timeSlot,
            maxCapacity: maxCap,
            guideId: guide.id,
            bookingId: bookingId,
            groupSize: groupSize,
          );
          guideAssignments[activity] = guide.id;
          slotAssignments[activity] = slotId;
        } else {
          // No guide available — flag for admin attention
          pendingActivity = activity;
          break;
        }
      }
    }

    if (pendingActivity != null) {
      await _db.collection('bookings').doc(bookingId).update({
        'status': 'Pending Guide',
        'pendingActivity': pendingActivity,
        'guideAssignments': guideAssignments,
        'slotAssignments': slotAssignments,
      });
    } else {
      await _db.collection('bookings').doc(bookingId).update({
        'status': 'Confirmed',
        'guideAssignments': guideAssignments,
        'slotAssignments': slotAssignments,
      });
    }
  }

  /// Finds an existing open slot for this activity/date/time that can fit [groupSize] more visitors.
  Future<QueryDocumentSnapshot?> _findOpenSlot(
    String activity,
    String date,
    String timeSlot,
    int groupSize,
    int maxCap,
  ) async {
    final query = await _db
        .collection('guide_slots')
        .where('activityId', isEqualTo: activity)
        .where('date', isEqualTo: date)
        .where('timeSlot', isEqualTo: timeSlot)
        .where('status', isEqualTo: 'open')
        .get();

    for (final doc in query.docs) {
      final filled = doc['filledSeats'] as int;
      if (filled + groupSize <= maxCap) return doc;
    }
    return null;
  }

  /// Finds an active guide who specializes in [activity] and is not already
  /// assigned to any slot on [date] + [timeSlot].
  /// Picks the guide with the lowest total assignments (fairest workload).
  Future<QueryDocumentSnapshot?> _findAvailableGuide(
    String activity,
    String date,
    String timeSlot,
  ) async {
    final guidesSnap = await _db
        .collection('guides')
        .where('isActive', isEqualTo: true)
        .where('specializations', arrayContains: activity)
        .get();

    if (guidesSnap.docs.isEmpty) return null;

    // Find guide IDs already busy at this date+timeSlot
    final busySnap = await _db
        .collection('guide_slots')
        .where('date', isEqualTo: date)
        .where('timeSlot', isEqualTo: timeSlot)
        .get();

    final busyGuideIds = busySnap.docs.map((d) => d['guideId'] as String).toSet();

    final available = guidesSnap.docs
        .where((g) => !busyGuideIds.contains(g.id))
        .toList();

    if (available.isEmpty) return null;

    // Sort by least total assignments for fair workload distribution
    available.sort((a, b) {
      final aLoad = (a.data()['totalAssignments'] ?? 0) as int;
      final bLoad = (b.data()['totalAssignments'] ?? 0) as int;
      return aLoad.compareTo(bLoad);
    });

    return available.first;
  }

  /// Creates a new guide slot in Firestore and returns its document ID.
  Future<String> _createSlot({
    required String activity,
    required String date,
    required String timeSlot,
    required int maxCapacity,
    required String guideId,
    required String bookingId,
    required int groupSize,
  }) async {
    final ref = await _db.collection('guide_slots').add({
      'activityId': activity,
      'date': date,
      'timeSlot': timeSlot,
      'maxCapacity': maxCapacity,
      'filledSeats': groupSize,
      'guideId': guideId,
      'status': groupSize >= maxCapacity ? 'full' : 'open',
      'bookingIds': [bookingId],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Track guide workload
    await _db.collection('guides').doc(guideId).update({
      'totalAssignments': FieldValue.increment(1),
    });

    return ref.id;
  }

  /// Adds a booking to an existing slot and updates seat count.
  Future<void> _addToSlot(String slotId, String bookingId, int groupSize) async {
    final slotRef = _db.collection('guide_slots').doc(slotId);
    final slot = await slotRef.get();
    final newFilled = (slot['filledSeats'] as int) + groupSize;
    final maxCap = slot['maxCapacity'] as int;

    await slotRef.update({
      'filledSeats': newFilled,
      'status': newFilled >= maxCap ? 'full' : 'open',
      'bookingIds': FieldValue.arrayUnion([bookingId]),
    });
  }

  /// Admin override: manually assign a specific guide to a pending booking.
  Future<void> manuallyAssignGuide({
    required String bookingId,
    required String activity,
    required String date,
    required String timeSlot,
    required String guideId,
    required int groupSize,
  }) async {
    final maxCap = guideCapacity[activity] ?? 10;

    // Check if this guide already has an open slot for this activity/date/time
    final existingSlot = await _db
        .collection('guide_slots')
        .where('activityId', isEqualTo: activity)
        .where('date', isEqualTo: date)
        .where('timeSlot', isEqualTo: timeSlot)
        .where('guideId', isEqualTo: guideId)
        .get();

    if (existingSlot.docs.isNotEmpty) {
      await _addToSlot(existingSlot.docs.first.id, bookingId, groupSize);
      await _db.collection('bookings').doc(bookingId).update({
        'status': 'Confirmed',
        'guideAssignments.$activity': guideId,
        'slotAssignments.$activity': existingSlot.docs.first.id,
        'pendingActivity': FieldValue.delete(),
      });
    } else {
      final slotId = await _createSlot(
        activity: activity,
        date: date,
        timeSlot: timeSlot,
        maxCapacity: maxCap,
        guideId: guideId,
        bookingId: bookingId,
        groupSize: groupSize,
      );
      await _db.collection('bookings').doc(bookingId).update({
        'status': 'Confirmed',
        'guideAssignments.$activity': guideId,
        'slotAssignments.$activity': slotId,
        'pendingActivity': FieldValue.delete(),
      });
    }
  }
}
