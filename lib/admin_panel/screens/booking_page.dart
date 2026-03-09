import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'payment_page.dart';

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
    timeSlots: [ "7–8 PM"],
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
      "10:00 AM - 10:30 AM",
      "10:30 AM - 11:00 AM",
      "11:00 AM - 11:30 AM",
      "11:30 AM - 12:00 PM",
      "12:00 PM - 12:30 PM",
      "12:30 PM - 1:00 PM",
      "1:00 PM - 1:30 PM",
      "1:30 PM - 2:00 PM",
      "2:00 PM - 2:30 PM",
      "2:30 PM - 3:00 PM",
      "3:00 PM - 3:30 PM",
      "3:30 PM - 4:00 PM",
      "4:00 PM - 4:30 PM",
      "4:30 PM - 5:00 PM",
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

  int domesticCount = 0;
  int saarcCount = 0;
  int touristCount = 0;

  bool showReview = false;

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

  ActivityInfo get _activity =>
      _firestoreInfo ?? activityData[widget.activityName] ?? ActivityInfo(
        name: widget.activityName,
        domestic: 0, saarc: 0, tourist: 0, timeSlots: [],
      );

  int totalPrice(ActivityInfo a) {
    return (domesticCount * a.domestic) +
        (saarcCount * a.saarc) +
        (touristCount * a.tourist);
  }

  Widget counterRow(String label, int price, int count, VoidCallback onAdd,
      VoidCallback onRemove) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text("$label (Rs. $price)",
              style: const TextStyle(fontSize: 14)),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: count > 0 ? onRemove : null,
            ),
            Text(
              "$count",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: onAdd,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activity = _activity;
    final total = totalPrice(activity);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: Text(widget.activityName),
        backgroundColor: const Color(0xFF4FBF26),
        centerTitle: true,
      ),
      body: _loadingActivity
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: showReview
                  ? _buildReview(activity, total)
                  : _buildBookingForm(activity, total),
            ),
    );
  }

  /// Booking Form
  Widget _buildBookingForm(ActivityInfo activity, int total) {
    return ListView(
      children: [
        // DATE PICKER + ICON
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardStyle(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select Date",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          selectedDate == null
                              ? "Choose a date"
                              : DateFormat('yyyy-MM-dd')
                              .format(selectedDate!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.schedule, color: Colors.green),
                    onPressed: selectedDate == null
                        ? null
                        : () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Available Slots for ${DateFormat('yyyy-MM-dd').format(selectedDate!)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(height: 12),
                                ...activity.timeSlots.map(
                                      (slot) => ListTile(
                                    title: Text(slot),
                                    leading: const Icon(Icons.circle,
                                        size: 12, color: Colors.green),
                                    onTap: () {
                                      setState(() {
                                        selectedTime = slot;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // TIME DROPDOWN
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardStyle(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select Time",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedTime.isEmpty ? null : selectedTime,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text('--- Select ---'),
                items: activity.timeSlots
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTime = value!;
                  });
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // VISITORS
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardStyle(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Visitors",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              counterRow(
                "Domestic (Nepal)",
                activity.domestic,
                domesticCount,
                    () => setState(() => domesticCount++),
                    () => setState(() => domesticCount--),
              ),
              counterRow(
                "SAARC Countries",
                activity.saarc,
                saarcCount,
                    () => setState(() => saarcCount++),
                    () => setState(() => saarcCount--),
              ),
              counterRow(
                "Other Tourists",
                activity.tourist,
                touristCount,
                    () => setState(() => touristCount++),
                    () => setState(() => touristCount--),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // TOTAL
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardStyle(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Total Amount",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                "Rs. $total",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // CONFIRM BUTTON
        SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FBF26),
            ),
            onPressed: total == 0 ||
                selectedDate == null ||
                selectedTime.isEmpty
                ? null
                : () {
              setState(() {
                showReview = true; // Switch to review
              });
            },
            child: const Text(
              "Continue",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  /// REVIEW BOOKING
  Widget _buildReview(ActivityInfo activity, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Booking Summary",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _summaryRow("Activity", widget.activityName),
        _summaryRow(
            "Date",
            selectedDate != null
                ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                : ""),
        _summaryRow("Time", selectedTime),
        const Divider(height: 30, thickness: 1),
        const Text("Visitors", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (domesticCount > 0) _summaryRow("Domestic (Nepal)", "$domesticCount"),
        if (saarcCount > 0) _summaryRow("SAARC Countries", "$saarcCount"),
        if (touristCount > 0) _summaryRow("Other Tourists", "$touristCount"),
        const Divider(height: 30, thickness: 1),
        _summaryRow("Total Amount", "Rs. $total"),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300),
                onPressed: () {
                  setState(() {
                    showReview = false; // Go back to edit
                  });
                },
                child: const Text("Edit", style: TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4FBF26)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentPage(
                        activityName: widget.activityName,
                        date: selectedDate!,
                        time: selectedTime,
                        totalAmount: total,
                      ),
                    ),
                  );
                },
                child: const Text("Pay", style: TextStyle(color: Colors.black)),
              ),

            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))],
      ),
    );
  }

  BoxDecoration _cardStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 6,
        ),
      ],
    );
  }
}
