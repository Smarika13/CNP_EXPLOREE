import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment_page.dart';
import '../shared/services/guide_scheduler_service.dart';

class ActivityInfo {
  final String name;
  final int domestic;
  final int saarc;
  final int tourist;
  final List<String> timeSlots;

  ActivityInfo({
    required this.name,
    required this.domestic,
    required this.saarc,
    required this.tourist,
    required this.timeSlots,
  });
}

final Map<String, ActivityInfo> activityData = {
  "Jeep Safari": ActivityInfo(
    name: "Jeep Safari",
    domestic: 500,
    saarc: 1500,
    tourist: 3500,
    timeSlots: ["6–10 AM", "2–5 PM"],
  ),
  "Bird Watching": ActivityInfo(
    name: "Bird Watching",
    domestic: 3000,
    saarc: 5500,
    tourist: 6500,
    timeSlots: ["6–10 AM", "2–5 PM"],
  ),
  "Elephant Safari": ActivityInfo(
    name: "Elephant Safari",
    domestic: 1650,
    saarc: 4000,
    tourist: 5000,
    timeSlots: ["6–10 AM", "2–5 PM"],
  ),
  "Tharu Cultural Program": ActivityInfo(
    name: "Tharu Cultural Program",
    domestic: 200,
    saarc: 300,
    tourist: 300,
    timeSlots: ["7–8 PM"],
  ),
  "Jungle Walk": ActivityInfo(
    name: "Jungle Walk",
    domestic: 5000,
    saarc: 10000,
    tourist: 12500,
    timeSlots: ["6–10 AM", "2–5 PM"],
  ),
  "Canoe Ride": ActivityInfo(
    name: "Canoe Ride",
    domestic: 500,
    saarc: 600,
    tourist: 700,
    timeSlots: ["6–10 AM", "2–5 PM"],
  ),
  "Tharu Museum": ActivityInfo(
    name: "Tharu Museum",
    domestic: 200,
    saarc: 400,
    tourist: 400,
    timeSlots: [
      "10:00 AM - 10:30 AM", "10:30 AM - 11:00 AM",
      "11:00 AM - 11:30 AM", "11:30 AM - 12:00 PM",
      "12:00 PM - 12:30 PM", "12:30 PM - 1:00 PM",
      "1:00 PM - 1:30 PM", "1:30 PM - 2:00 PM",
      "2:00 PM - 2:30 PM", "2:30 PM - 3:00 PM",
      "3:00 PM - 3:30 PM", "3:30 PM - 4:00 PM",
      "4:00 PM - 4:30 PM", "4:30 PM - 5:00 PM",
    ],
  ),
};

class BookingPage extends StatefulWidget {
  final String activityName;
  const BookingPage({super.key, required this.activityName});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String selectedTime = "";
  DateTime? selectedDate;
  int domesticCount = 0, saarcCount = 0, touristCount = 0;
  bool showReview = false, isSaving = false;

  // Capacity state — updated whenever date + time slot are both chosen
  SlotCapacity? _slotCapacity;
  bool _fetchingCapacity = false;

  // Activity info loaded from Firestore (falls back to hardcoded map)
  ActivityInfo? _firestoreInfo;
  bool _loadingActivity = true;

  @override
  void initState() {
    super.initState();
    _loadActivityFromFirestore();
  }

  Future<void> _loadActivityFromFirestore() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('activities')
          .where('title', isEqualTo: widget.activityName)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        final d = snap.docs.first.data();
        _firestoreInfo = ActivityInfo(
          name: widget.activityName,
          domestic: (d['domestic'] as num?)?.toInt() ?? 0,
          saarc: (d['saarc'] as num?)?.toInt() ?? 0,
          tourist: (d['tourist'] as num?)?.toInt() ?? 0,
          timeSlots: List<String>.from(d['timeSlots'] ?? []),
        );
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingActivity = false);
  }

  ActivityInfo? get _activityInfo => _firestoreInfo ?? activityData[widget.activityName];

  int calculateGrandTotal() {
    final info = _activityInfo;
    if (info == null) return 0;
    return (domesticCount * info.domestic) +
           (saarcCount * info.saarc) +
           (touristCount * info.tourist);
  }

  String _toLocalNum(int n) {
    if (context.locale.languageCode != 'ne') return '$n';
    const digits = ['०','१','२','३','४','५','६','७','८','९'];
    return '$n'.split('').map((c) {
      final d = int.tryParse(c);
      return d != null ? digits[d] : c;
    }).join();
  }

  String _translateTimeSlot(String slot) {
    switch (slot) {
      case '6–10 AM': return 'slot_morning'.tr();
      case '2–5 PM':  return 'slot_afternoon'.tr();
      case '7–8 PM':  return 'slot_evening'.tr();
      default: return slot; // Tharu Museum minute-by-minute slots stay as-is
    }
  }

  String _translatedActivityName(String name) {
    switch (name.toLowerCase()) {
      case 'jeep safari': return 'activity_jeep_safari'.tr();
      case 'bird watching': return 'activity_bird_watching'.tr();
      case 'elephant safari': return 'activity_elephant_safari'.tr();
      case 'jungle walk': return 'activity_jungle_walk'.tr();
      case 'canoe ride': return 'activity_canoe_ride'.tr();
      case 'tharu cultural program': return 'activity_tharu_cultural'.tr();
      case 'tharu museum': return 'activity_tharu_museum'.tr();
      default: return name;
    }
  }

  Future<void> _saveToFirebase(int total) async {
    setState(() => isSaving = true);
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("No user logged in. Please sign in to book.");
      }

      // Check availability before saving — block if slot is full
      final groupSize = domesticCount + saarcCount + touristCount;
      final unavailableReason = await GuideSchedulerService().checkAvailability(
        activity: widget.activityName,
        date: DateFormat('yyyy-MM-dd').format(selectedDate!),
        timeSlot: selectedTime,
        groupSize: groupSize,
      );
      if (unavailableReason != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(unavailableReason),
              backgroundColor: Colors.red.shade700,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // Logic to fetch the Name for the Admin Portal
      String nameToSave = user.displayName ?? user.email?.split('@')[0] ?? "Guest User";

      final docRef = await FirebaseFirestore.instance.collection('bookings').add({
        'userId': user.uid,
        'userName': nameToSave,
        'activity': widget.activityName,
        'date': selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : "",
        'time': selectedTime,
        'visitorCounts': {
          'domestic': domesticCount,
          'saarc': saarcCount,
          'tourist': touristCount,
        },
        'totalAmount': total,
        'status': 'Confirmed',
        'bookingTimestamp': FieldValue.serverTimestamp(),
      });

      // Guide assignment and email notification are sent AFTER payment (in PaymentPage)
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(
              activityName: widget.activityName,
              date: selectedDate!,
              time: selectedTime,
              totalAmount: total,
              bookingId: docRef.id,
              groupSize: groupSize,
              visitorName: nameToSave,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  /// Parses the START hour from slot strings like:
  /// "6–10 AM" → 6,  "2–5 PM" → 14,  "10:00 AM - 10:30 AM" → 10,  "7–8 PM" → 19
  int _slotStartHour(String slot) {
    try {
      // Format: "10:00 AM - 10:30 AM"
      if (slot.contains(':')) {
        final parts = slot.split(RegExp(r'\s*-\s*'));
        final timePart = parts.first.trim(); // "10:00 AM"
        final isPm = timePart.toUpperCase().contains('PM');
        final hour = int.parse(timePart.split(':').first.replaceAll(RegExp(r'[^0-9]'), ''));
        if (isPm && hour != 12) return hour + 12;
        if (!isPm && hour == 12) return 0;
        return hour;
      }
      // Format: "6–10 AM" or "2–5 PM"
      final isPm = slot.toUpperCase().contains('PM');
      final hour = int.parse(slot.replaceAll(RegExp(r'[^0-9].*'), '').trim());
      if (isPm && hour != 12) return hour + 12;
      if (!isPm && hour == 12) return 0;
      return hour;
    } catch (_) {
      return 0;
    }
  }

  List<String> getAvailableTimeSlots() {
    final all = _activityInfo?.timeSlots ?? [];
    if (selectedDate == null) return all;

    final now = DateTime.now();
    final isToday = selectedDate!.year == now.year &&
        selectedDate!.month == now.month &&
        selectedDate!.day == now.day;

    if (!isToday) return all;

    // For today: only show slots whose start time is still in the future
    return all.where((slot) => _slotStartHour(slot) > now.hour).toList();
  }

  Future<void> _fetchCapacity() async {
    if (selectedDate == null || selectedTime.isEmpty) return;
    setState(() { _fetchingCapacity = true; _slotCapacity = null; });
    final cap = await GuideSchedulerService().getAvailableCapacity(
      activity: widget.activityName,
      date: DateFormat('yyyy-MM-dd').format(selectedDate!),
      timeSlot: selectedTime,
    );
    if (mounted) setState(() { _slotCapacity = cap; _fetchingCapacity = false; });
  }

  @override
  Widget build(BuildContext context) {
    final total = calculateGrandTotal();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: Text('booking_title'.tr()),
        backgroundColor: const Color(0xFF4FBF26),
        centerTitle: true,
      ),
      body: _loadingActivity
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: showReview ? _buildReview(total) : _buildBookingForm(total),
            ),
    );
  }

  Widget _buildBookingForm(int total) {
    final info = _activityInfo;
    final int unitPriceDomestic = info?.domestic ?? 0;
    final int unitPriceSaarc = info?.saarc ?? 0;
    final int unitPriceTourist = info?.tourist ?? 0;

    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardStyle(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('booking_selected_activity'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Chip(
                label: Text(_translatedActivityName(widget.activityName), style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.green.shade100,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardStyle(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('booking_select_date'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(selectedDate == null
                          ? 'booking_choose_date'.tr()
                          : DateFormat('yyyy-MM-dd').format(selectedDate!)),
                      const Icon(Icons.calendar_today, color: Colors.green, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardStyle(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('booking_select_time'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedTime.isEmpty ? null : selectedTime,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: Text('booking_select_hint'.tr()),
                items: getAvailableTimeSlots()
                    .map((t) => DropdownMenuItem(value: t, child: Text(_translateTimeSlot(t))))
                    .toList(),
                onChanged: (value) {
                  setState(() { selectedTime = value!; _slotCapacity = null; });
                  _fetchCapacity();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardStyle(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('booking_visitors'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  if (_fetchingCapacity)
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  if (!_fetchingCapacity && _slotCapacity != null && selectedTime.isNotEmpty)
                    _CapacityBadge(_slotCapacity!),
                ],
              ),
              if (!_fetchingCapacity && _slotCapacity != null && _slotCapacity!.isFull)
                _fullSlotBanner()
              else if (!_fetchingCapacity && _slotCapacity != null && !_slotCapacity!.guidesAvailable)
                _noGuideBanner(),
              _counterRow(
                  'booking_domestic'.tr(),
                  "${'currency'.tr()} ${_toLocalNum(unitPriceDomestic)}${'booking_per_person'.tr()}",
                  domesticCount,
                  () => setState(() => domesticCount++),
                  () => setState(() => domesticCount--)),
              _counterRow(
                  'booking_saarc'.tr(),
                  "${'currency'.tr()} ${_toLocalNum(unitPriceSaarc)}${'booking_per_person'.tr()}",
                  saarcCount,
                  () => setState(() => saarcCount++),
                  () => setState(() => saarcCount--)),
              _counterRow(
                  'booking_tourist'.tr(),
                  "${'currency'.tr()} ${_toLocalNum(unitPriceTourist)}${'booking_per_person'.tr()}",
                  touristCount,
                  () => setState(() => touristCount++),
                  () => setState(() => touristCount--)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardStyle(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('booking_total'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text("${'currency'.tr()} ${_toLocalNum(total)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4FBF26)),
            onPressed: total == 0 || selectedDate == null || selectedTime.isEmpty || _slotBlocked
                ? null
                : () => setState(() => showReview = true),
            child: Text('booking_continue'.tr(), style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildReview(int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('booking_summary_title'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _summaryRow('booking_summary_activity'.tr(), _translatedActivityName(widget.activityName)),
        _summaryRow('booking_summary_date'.tr(), DateFormat('yyyy-MM-dd').format(selectedDate!)),
        _summaryRow('booking_summary_time'.tr(), _translateTimeSlot(selectedTime)),
        const Divider(height: 30, thickness: 1),
        Text('booking_summary_visitors'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        if (domesticCount > 0) _summaryRow('booking_summary_domestic'.tr(), _toLocalNum(domesticCount)),
        if (saarcCount > 0) _summaryRow('booking_summary_saarc'.tr(), _toLocalNum(saarcCount)),
        if (touristCount > 0) _summaryRow('booking_summary_tourist'.tr(), _toLocalNum(touristCount)),
        const Divider(height: 30, thickness: 1),
        _summaryRow('booking_summary_total'.tr(), "${'currency'.tr()} ${_toLocalNum(total)}"),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300),
                onPressed: () => setState(() => showReview = false),
                child: Text('booking_edit'.tr(), style: const TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4FBF26)),
                onPressed: isSaving ? null : () => _saveToFirebase(total),
                child: isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : Text('booking_confirm_pay'.tr(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _counterRow(String label, String priceUnit, int count, VoidCallback onAdd, VoidCallback onRemove) {
    final totalVisitors = domesticCount + saarcCount + touristCount;
    final capacityReached = _slotCapacity != null && totalVisitors >= _slotCapacity!.remainingVisitors;
    final noGuides = _slotCapacity != null && !_slotCapacity!.guidesAvailable && totalVisitors >= _slotCapacity!.remainingVisitors;
    final canAdd = !capacityReached && !noGuides;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              Text(priceUnit, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.remove), onPressed: count > 0 ? onRemove : null),
            Text(_toLocalNum(count)),
            IconButton(
              icon: Icon(Icons.add, color: canAdd ? null : Colors.grey.shade400),
              onPressed: canAdd ? onAdd : () {
                final msg = _slotCapacity!.isFull
                    ? 'This slot is fully booked. Please choose a different date or time.'
                    : !_slotCapacity!.guidesAvailable
                        ? 'No guides available for this slot. Please choose a different date or time.'
                        : 'Maximum capacity reached for this slot (${_slotCapacity!.remainingVisitors} visitors allowed).';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700, duration: const Duration(seconds: 3)),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _fullSlotBanner() => Container(
    margin: const EdgeInsets.only(top: 10, bottom: 4),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
    child: Row(children: [
      Icon(Icons.block, color: Colors.red.shade700, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Text('This slot is fully booked. Please choose a different date or time.', style: TextStyle(color: Colors.red.shade700, fontSize: 12))),
    ]),
  );

  Widget _noGuideBanner() => Container(
    margin: const EdgeInsets.only(top: 10, bottom: 4),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
    child: Row(children: [
      Icon(Icons.person_off, color: Colors.orange.shade800, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Text('No guides available for this slot. Please choose a different date or time.', style: TextStyle(color: Colors.orange.shade800, fontSize: 12))),
    ]),
  );

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardStyle() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
  );

  // disable the Continue button when slot is fully booked
  bool get _slotBlocked =>
      _slotCapacity != null && (_slotCapacity!.isFull || !_slotCapacity!.guidesAvailable);

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedTime = '';
        _slotCapacity = null;
      });
    }
  }
}

class _CapacityBadge extends StatelessWidget {
  final SlotCapacity capacity;
  const _CapacityBadge(this.capacity);

  @override
  Widget build(BuildContext context) {
    final isFull = capacity.isFull;
    final noGuide = !capacity.guidesAvailable;
    final color = isFull || noGuide ? Colors.red.shade700 : Colors.green.shade700;
    final bg    = isFull || noGuide ? Colors.red.shade50   : Colors.green.shade50;
    final label = isFull
        ? 'Full'
        : noGuide
            ? 'No guides'
            : '${capacity.remainingVisitors} left';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}