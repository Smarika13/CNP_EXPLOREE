import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Returned by [GuideSchedulerService.getAvailableCapacity].
class SlotCapacity {
  final int remainingVisitors; // how many more visitors can book
  final bool guidesAvailable;  // false only when guide is the bottleneck

  const SlotCapacity({required this.remainingVisitors, required this.guidesAvailable});

  bool get isFull => remainingVisitors <= 0;
}

class GuideSchedulerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Max visitors per physical unit (jeep / boat / elephant / guide group) ──
  static const Map<String, int> capacityPerSlot = {
    'Jeep Safari':             10,
    'Canoe Ride':              10,
    'Bird Watching':            6,
    'Elephant Safari':          4,
    'Jungle Walk':              5,
    'Tharu Cultural Program': 200,
    'Tharu Museum':           300,
  };

  // ── Total physical resources available per time-slot ──
  static const Map<String, int> resourceLimit = {
    'Jeep Safari':    25,   // 25 jeeps
    'Canoe Ride':     20,   // 20 boats
    'Elephant Safari': 10,  // 10 elephants
  };

  // ── Activities that require a guide assigned ──
  static const Set<String> needsGuide = {
    'Jeep Safari', 'Canoe Ride', 'Bird Watching', 'Jungle Walk',
  };

  // ── Venue activities: fixed seat pool, no guide / vehicle ──
  static const Set<String> venueActivities = {
    'Tharu Cultural Program',
    'Tharu Museum',
  };

  // ─────────────────────────────────────────────────────────────────────────
  // Live capacity query — call whenever date/time changes to update the UI.
  // ─────────────────────────────────────────────────────────────────────────

  Future<SlotCapacity> getAvailableCapacity({
    required String activity,
    required String date,
    required String timeSlot,
  }) async {
    if (venueActivities.contains(activity)) {
      return _venueCapacity(activity, date, timeSlot);
    } else if (!needsGuide.contains(activity)) {
      return _resourceCapacity(activity, date, timeSlot);
    } else {
      return _guideCapacity(activity, date, timeSlot);
    }
  }

  Future<SlotCapacity> _venueCapacity(String activity, String date, String timeSlot) async {
    final maxCap = capacityPerSlot[activity]!;
    final snap = await _db
        .collection('guide_slots')
        .where('activityId', isEqualTo: activity)
        .where('date', isEqualTo: date)
        .where('timeSlot', isEqualTo: timeSlot)
        .where('slotType', isEqualTo: 'venue')
        .get();
    final filled = snap.docs.isEmpty ? 0 : snap.docs.first['filledSeats'] as int;
    return SlotCapacity(remainingVisitors: (maxCap - filled).clamp(0, maxCap), guidesAvailable: true);
  }

  Future<SlotCapacity> _resourceCapacity(String activity, String date, String timeSlot) async {
    final maxCap = capacityPerSlot[activity]!;
    final limit  = resourceLimit[activity]!;

    final openSnap = await _db
        .collection('guide_slots')
        .where('activityId', isEqualTo: activity)
        .where('date', isEqualTo: date)
        .where('timeSlot', isEqualTo: timeSlot)
        .where('slotType', isEqualTo: 'resource')
        .where('status', isEqualTo: 'open')
        .get();
    int remaining = openSnap.docs.fold(0, (sum, d) => sum + (maxCap - (d['filledSeats'] as int)));

    final allSnap = await _db
        .collection('guide_slots')
        .where('activityId', isEqualTo: activity)
        .where('date', isEqualTo: date)
        .where('timeSlot', isEqualTo: timeSlot)
        .where('slotType', isEqualTo: 'resource')
        .get();
    final newSlotsPossible = limit - allSnap.docs.length;
    remaining += newSlotsPossible * maxCap;

    return SlotCapacity(
      remainingVisitors: remaining.clamp(0, limit * maxCap),
      guidesAvailable: true,
    );
  }

  Future<SlotCapacity> _guideCapacity(String activity, String date, String timeSlot) async {
    final maxCap = capacityPerSlot[activity]!;

    final openSnap = await _db
        .collection('guide_slots')
        .where('activityId', isEqualTo: activity)
        .where('date', isEqualTo: date)
        .where('timeSlot', isEqualTo: timeSlot)
        .where('slotType', isEqualTo: 'guide')
        .where('status', isEqualTo: 'open')
        .get();
    int remaining = openSnap.docs.fold(0, (sum, d) => sum + (maxCap - (d['filledSeats'] as int)));

    // Count free guides
    final guidesSnap = await _db.collection('guides').where('isActive', isEqualTo: true).get();
    final busySnap = await _db
        .collection('guide_slots')
        .where('date', isEqualTo: date)
        .where('timeSlot', isEqualTo: timeSlot)
        .get();
    final busyIds = busySnap.docs
        .where((d) => (d.data()['guideId'] as String? ?? '').isNotEmpty)
        .map((d) => d['guideId'] as String)
        .toSet();
    int freeGuides = guidesSnap.docs.where((g) => !busyIds.contains(g.id)).length;

    // If vehicle-limited, also constrain by free vehicles
    if (resourceLimit.containsKey(activity)) {
      final allSnap = await _db
          .collection('guide_slots')
          .where('activityId', isEqualTo: activity)
          .where('date', isEqualTo: date)
          .where('timeSlot', isEqualTo: timeSlot)
          .get();
      final freeVehicles = resourceLimit[activity]! - allSnap.docs.length;
      freeGuides = min(freeGuides, freeVehicles);
    }

    remaining += freeGuides.clamp(0, 9999) * maxCap;
    final guidesAvailable = freeGuides > 0 || openSnap.docs.isNotEmpty;
    return SlotCapacity(remainingVisitors: remaining, guidesAvailable: guidesAvailable);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Pre-booking availability check — call BEFORE saving to Firestore.
  // Returns null if the slot is available, or an error message if not.
  // ─────────────────────────────────────────────────────────────────────────

  Future<String?> checkAvailability({
    required String activity,
    required String date,
    required String timeSlot,
    required int groupSize,
  }) async {
    if (venueActivities.contains(activity)) {
      return _checkVenueAvailability(activity, date, timeSlot, groupSize);
    } else if (!needsGuide.contains(activity)) {
      // Elephant Safari — resource only
      return _checkResourceAvailability(activity, date, timeSlot, groupSize);
    } else {
      // Jeep Safari / Canoe Ride / Bird Watching / Jungle Walk
      return _checkGuideAvailability(activity, date, timeSlot, groupSize);
    }
  }

  Future<String?> _checkVenueAvailability(
      String activity, String date, String timeSlot, int groupSize) async {
    final maxCap = capacityPerSlot[activity]!;
    final snap = await _db
        .collection('guide_slots')
        .where('activityId', isEqualTo: activity)
        .where('date', isEqualTo: date)
        .where('timeSlot', isEqualTo: timeSlot)
        .where('slotType', isEqualTo: 'venue')
        .get();

    if (snap.docs.isNotEmpty) {
      final filled = snap.docs.first['filledSeats'] as int;
      final remaining = maxCap - filled;
      if (remaining <= 0) {
        return 'Sorry, $activity is fully booked for this time slot. Please choose a different time or date.';
      }
    }
    return null;
  }

  Future<String?> _checkResourceAvailability(
      String activity, String date, String timeSlot, int groupSize) async {
    final maxCap = capacityPerSlot[activity]!;
    final limit  = resourceLimit[activity]!;

    // Count total remaining capacity across all open slots
    final openSnap = await _db
        .collection('guide_slots')
        .where('activityId', isEqualTo: activity)
        .where('date', isEqualTo: date)
        .where('timeSlot', isEqualTo: timeSlot)
        .where('slotType', isEqualTo: 'resource')
        .where('status', isEqualTo: 'open')
        .get();

    int totalRemaining = openSnap.docs.fold(0, (sum, d) {
      return sum + (maxCap - (d['filledSeats'] as int));
    });

    // Count new slots we can still create
    final allSnap = await _db
        .collection('guide_slots')
        .where('activityId', isEqualTo: activity)
        .where('date', isEqualTo: date)
        .where('timeSlot', isEqualTo: timeSlot)
        .where('slotType', isEqualTo: 'resource')
        .get();

    final newSlotsPossible = limit - allSnap.docs.length;
    totalRemaining += newSlotsPossible * maxCap;

    if (groupSize > totalRemaining) {
      return 'Sorry, $activity is fully booked for this time slot. Please choose a different time or date.';
    }
    return null;
  }

  Future<String?> _checkGuideAvailability(
      String activity, String date, String timeSlot, int groupSize) async {
    final maxCap = capacityPerSlot[activity]!;

    // Calculate remaining capacity in existing open guide slots
    final openSnap = await _db
        .collection('guide_slots')
        .where('activityId', isEqualTo: activity)
        .where('date', isEqualTo: date)
        .where('timeSlot', isEqualTo: timeSlot)
        .where('slotType', isEqualTo: 'guide')
        .where('status', isEqualTo: 'open')
        .get();

    int totalRemaining = openSnap.docs.fold(0, (sum, d) {
      return sum + (maxCap - (d['filledSeats'] as int));
    });

    if (groupSize <= totalRemaining) return null; // fits in existing slots

    // Need new guide slots — check vehicle limit (if applicable)
    int visitorsStillNeeding = groupSize - totalRemaining;

    if (resourceLimit.containsKey(activity)) {
      final allSnap = await _db
          .collection('guide_slots')
          .where('activityId', isEqualTo: activity)
          .where('date', isEqualTo: date)
          .where('timeSlot', isEqualTo: timeSlot)
          .get();
      final vehiclesFree = resourceLimit[activity]! - allSnap.docs.length;
      if (vehiclesFree <= 0) {
        return 'Sorry, all ${_vehicleName(activity)} for $activity are fully booked for this time slot. Please choose a different time or date.';
      }
      // Capacity from new vehicle slots
      totalRemaining += vehiclesFree * maxCap;
      if (groupSize > totalRemaining) {
        return 'Sorry, not enough ${_vehicleName(activity)} available for $groupSize visitors at this time slot. Please split your group or choose another time.';
      }
      visitorsStillNeeding = groupSize - (totalRemaining - vehiclesFree * maxCap);
    }

    // Check guide availability
    final guide = await _findAvailableGuide(date, timeSlot);
    if (guide == null) {
      return 'No guides are available for this time slot. Please choose a different time or date.';
    }
    return null;
  }

  String _vehicleName(String activity) {
    switch (activity) {
      case 'Jeep Safari': return 'jeeps';
      case 'Canoe Ride':  return 'boats';
      default:            return 'resources';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Public entry point — called after a booking is saved to Firestore
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> assignGuidesForBooking({
    required String bookingId,
    required List<String> activities,
    required String date,
    required String timeSlot,
    required int groupSize,
  }) async {
    final Map<String, dynamic> slotAssignments = {};
    bool hasPending = false;

    for (final activity in activities) {
      if (venueActivities.contains(activity)) {
        // Tharu Cultural Program / Tharu Museum
        final ok = await _assignVenueSeats(
            bookingId, activity, date, timeSlot, groupSize, slotAssignments);
        if (!ok) hasPending = true;
      } else if (!needsGuide.contains(activity)) {
        // Elephant Safari — resource-limited, no guide
        final ok = await _assignResourceSlot(
            bookingId, activity, date, timeSlot, groupSize, slotAssignments);
        if (!ok) hasPending = true;
      } else {
        // Jeep Safari / Canoe Ride / Bird Watching / Jungle Walk
        final ok = await _assignGuideSlot(
            bookingId, activity, date, timeSlot, groupSize, slotAssignments);
        if (!ok) hasPending = true;
      }
      if (hasPending) break;
    }

    await _db.collection('bookings').doc(bookingId).update({
      'status': 'Confirmed',
      'slotAssignments': slotAssignments,
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Venue activities (Tharu Cultural Program, Tharu Museum)
  // Single large-capacity slot per activity / date / time-slot
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> _assignVenueSeats(
    String bookingId,
    String activity,
    String date,
    String timeSlot,
    int groupSize,
    Map<String, dynamic> slotAssignments,
  ) async {
    final maxCap = capacityPerSlot[activity]!;

    final snap = await _db
        .collection('guide_slots')
        .where('activityId', isEqualTo: activity)
        .where('date', isEqualTo: date)
        .where('timeSlot', isEqualTo: timeSlot)
        .where('slotType', isEqualTo: 'venue')
        .get();

    if (snap.docs.isNotEmpty) {
      final doc = snap.docs.first;
      final filled = doc['filledSeats'] as int;
      final canFit = min(groupSize, maxCap - filled);
      if (canFit <= 0) return false; // venue full
      await _addToSlot(doc.id, bookingId, canFit);
      slotAssignments[activity] = doc.id;
    } else {
      if (groupSize > maxCap) return false;
      final ref = await _db.collection('guide_slots').add({
        'activityId': activity,
        'date': date,
        'timeSlot': timeSlot,
        'slotType': 'venue',
        'maxCapacity': maxCap,
        'filledSeats': groupSize,
        'guideId': '',
        'status': groupSize >= maxCap ? 'full' : 'open',
        'bookingIds': [bookingId],
        'createdAt': FieldValue.serverTimestamp(),
      });
      slotAssignments[activity] = ref.id;
    }
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Resource-limited, no-guide activities (Elephant Safari)
  // Each slot = 1 elephant (max 4 users). Limit: 10 elephants per time-slot.
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> _assignResourceSlot(
    String bookingId,
    String activity,
    String date,
    String timeSlot,
    int groupSize,
    Map<String, dynamic> slotAssignments,
  ) async {
    final maxCap = capacityPerSlot[activity]!;
    final limit  = resourceLimit[activity]!;
    int remaining = groupSize;

    while (remaining > 0) {
      // Try to fill existing open resource slot (most-filled first)
      final openSnap = await _db
          .collection('guide_slots')
          .where('activityId', isEqualTo: activity)
          .where('date', isEqualTo: date)
          .where('timeSlot', isEqualTo: timeSlot)
          .where('slotType', isEqualTo: 'resource')
          .where('status', isEqualTo: 'open')
          .get();

      final open = openSnap.docs
          .where((d) => (d['filledSeats'] as int) < maxCap)
          .toList()
        ..sort((a, b) =>
            (b['filledSeats'] as int).compareTo(a['filledSeats'] as int));

      if (open.isNotEmpty) {
        final doc    = open.first;
        final filled = doc['filledSeats'] as int;
        final canFit = min(remaining, maxCap - filled);
        await _addToSlot(doc.id, bookingId, canFit);
        slotAssignments[activity] = doc.id;
        remaining -= canFit;
      } else {
        // Check whether we've hit the resource limit
        final allSnap = await _db
            .collection('guide_slots')
            .where('activityId', isEqualTo: activity)
            .where('date', isEqualTo: date)
            .where('timeSlot', isEqualTo: timeSlot)
            .where('slotType', isEqualTo: 'resource')
            .get();

        if (allSnap.docs.length >= limit) return false; // all resources in use

        final canFit = min(remaining, maxCap);
        final ref = await _db.collection('guide_slots').add({
          'activityId': activity,
          'date': date,
          'timeSlot': timeSlot,
          'slotType': 'resource',
          'maxCapacity': maxCap,
          'filledSeats': canFit,
          'guideId': '',
          'status': canFit >= maxCap ? 'full' : 'open',
          'bookingIds': [bookingId],
          'createdAt': FieldValue.serverTimestamp(),
        });
        slotAssignments[activity] = ref.id;
        remaining -= canFit;
      }
    }
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Guide activities
  //   • Jeep Safari / Canoe Ride : vehicle limit (25 / 20) + 1 guide each
  //   • Bird Watching / Jungle Walk : unlimited groups, 1 guide each
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> _assignGuideSlot(
    String bookingId,
    String activity,
    String date,
    String timeSlot,
    int groupSize,
    Map<String, dynamic> slotAssignments,
  ) async {
    final maxCap = capacityPerSlot[activity]!;
    int remaining = groupSize;

    while (remaining > 0) {
      // 1. Try to fill an existing open guide slot for this activity
      final openSlot = await _findOpenGuideSlot(activity, date, timeSlot, maxCap);

      if (openSlot != null) {
        final filled = openSlot['filledSeats'] as int;
        final canFit = min(remaining, maxCap - filled);
        await _addToSlot(openSlot.id, bookingId, canFit);
        slotAssignments[activity] = openSlot.id;
        remaining -= canFit;
      } else {
        // 2. For vehicle activities, check vehicle limit before creating a new slot
        if (resourceLimit.containsKey(activity)) {
          final allSnap = await _db
              .collection('guide_slots')
              .where('activityId', isEqualTo: activity)
              .where('date', isEqualTo: date)
              .where('timeSlot', isEqualTo: timeSlot)
              .get();
          if (allSnap.docs.length >= resourceLimit[activity]!) return false;
        }

        // 3. Find an available guide (FCFS — by createdAt)
        final guide = await _findAvailableGuide(date, timeSlot);
        if (guide == null) return false;

        final canFit = min(remaining, maxCap);
        final ref = await _db.collection('guide_slots').add({
          'activityId': activity,
          'date': date,
          'timeSlot': timeSlot,
          'slotType': 'guide',
          'maxCapacity': maxCap,
          'filledSeats': canFit,
          'guideId': guide.id,
          'status': canFit >= maxCap ? 'full' : 'open',
          'bookingIds': [bookingId],
          'createdAt': FieldValue.serverTimestamp(),
        });

        slotAssignments[activity] = ref.id;
        remaining -= canFit;
      }
    }
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  Future<QueryDocumentSnapshot?> _findOpenGuideSlot(
    String activity,
    String date,
    String timeSlot,
    int maxCap,
  ) async {
    final snap = await _db
        .collection('guide_slots')
        .where('activityId', isEqualTo: activity)
        .where('date', isEqualTo: date)
        .where('timeSlot', isEqualTo: timeSlot)
        .where('slotType', isEqualTo: 'guide')
        .where('status', isEqualTo: 'open')
        .get();

    final open = snap.docs
        .where((d) => (d['filledSeats'] as int) < maxCap)
        .toList()
      ..sort((a, b) =>
          (b['filledSeats'] as int).compareTo(a['filledSeats'] as int));

    return open.isEmpty ? null : open.first;
  }

  /// Returns the next available guide using Least-Assigned First.
  /// Among free guides, picks the one with fewest total guide_slots.
  /// Tie-breaks by createdAt (earliest registered wins).
  /// A guide is considered busy if they already have ANY slot at this date+timeSlot.
  Future<QueryDocumentSnapshot?> _findAvailableGuide(
      String date, String timeSlot) async {
    final guidesSnap = await _db
        .collection('guides')
        .where('isActive', isEqualTo: true)
        .get();

    if (guidesSnap.docs.isEmpty) return null;

    final busySnap = await _db
        .collection('guide_slots')
        .where('date', isEqualTo: date)
        .where('timeSlot', isEqualTo: timeSlot)
        .get();

    final busyIds = busySnap.docs
        .where((d) => (d.data()['guideId'] as String? ?? '').isNotEmpty)
        .map((d) => d['guideId'] as String)
        .toSet();

    final available =
        guidesSnap.docs.where((g) => !busyIds.contains(g.id)).toList();

    if (available.isEmpty) return null;

    // Count live assignments for each free guide from guide_slots
    final counts = await Future.wait(available.map((g) async {
      final snap = await _db
          .collection('guide_slots')
          .where('guideId', isEqualTo: g.id)
          .get();
      return snap.docs.length;
    }));

    // Least-Assigned First: fewest slots → highest priority
    // Tie-break: earliest createdAt (registration order)
    available.sort((a, b) {
      final ai = available.indexOf(a);
      final bi = available.indexOf(b);
      if (counts[ai] != counts[bi]) return counts[ai].compareTo(counts[bi]);
      final aTs = a.data()['createdAt'] as Timestamp?;
      final bTs = b.data()['createdAt'] as Timestamp?;
      if (aTs == null && bTs == null) return 0;
      if (aTs == null) return 1;
      if (bTs == null) return -1;
      return aTs.compareTo(bTs);
    });

    return available.first;
  }

  Future<void> _addToSlot(
      String slotId, String bookingId, int seatsToAdd) async {
    final slotRef = _db.collection('guide_slots').doc(slotId);
    final snap    = await slotRef.get();
    final maxCap    = snap['maxCapacity'] as int;
    // Hard cap: never let filledSeats exceed maxCapacity
    final newFilled = min((snap['filledSeats'] as int) + seatsToAdd, maxCap);

    await slotRef.update({
      'filledSeats': newFilled,
      'status': newFilled >= maxCap ? 'full' : 'open',
      'bookingIds': FieldValue.arrayUnion([bookingId]),
    });
  }

  /// Admin override: manually assign a specific guide to a booking.
  Future<void> manuallyAssignGuide({
    required String bookingId,
    required String activity,
    required String date,
    required String timeSlot,
    required String guideId,
    required int groupSize,
  }) async {
    final maxCap = capacityPerSlot[activity] ?? 10;

    final existing = await _db
        .collection('guide_slots')
        .where('activityId', isEqualTo: activity)
        .where('date', isEqualTo: date)
        .where('timeSlot', isEqualTo: timeSlot)
        .where('guideId', isEqualTo: guideId)
        .get();

    if (existing.docs.isNotEmpty) {
      await _addToSlot(existing.docs.first.id, bookingId, groupSize);
    } else {
      await _db.collection('guide_slots').add({
        'activityId': activity,
        'date': date,
        'timeSlot': timeSlot,
        'slotType': 'guide',
        'maxCapacity': maxCap,
        'filledSeats': min(groupSize, maxCap),
        'guideId': guideId,
        'status': groupSize >= maxCap ? 'full' : 'open',
        'bookingIds': [bookingId],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await _db.collection('bookings').doc(bookingId).update({
      'status': 'Confirmed',
      'guideAssignments.$activity': guideId,
      'pendingActivity': FieldValue.delete(),
    });
  }
}
