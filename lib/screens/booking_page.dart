import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
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
  // UPDATED: Now accepts a list of activities
  final List<String> activityList;

  const BookingPage({super.key, required this.activityList});

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
  bool isSaving = false; 

  // UPDATED: Calculates total for ALL selected activities
  int calculateGrandTotal() {
    int total = 0;
    for (var actName in widget.activityList) {
      final info = activityData[actName];
      if (info != null) {
        total += (domesticCount * info.domestic) +
                 (saarcCount * info.saarc) +
                 (touristCount * info.tourist);
      }
    }
    return total;
  }

  // Helper to save to Firestore
  Future<void> _saveToFirebase(int total) async {
    setState(() => isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'activities': widget.activityList, // Saved as array
        'date': selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : "",
        'time': selectedTime,
        'visitorCounts': {
          'domestic': domesticCount,
          'saarc': saarcCount,
          'tourist': touristCount,
        },
        'totalAmount': total,
        'status': 'Pending',
        'bookingTimestamp': FieldValue.serverTimestamp(),
      });
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(
              activityName: widget.activityList.join(", "),
              date: selectedDate!,
              time: selectedTime,
              totalAmount: total,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving booking: $e")),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  // Common time slots intersection (optional: uses slots from first activity)
  List<String> getAvailableTimeSlots() {
    if (widget.activityList.isEmpty) return [];
    return activityData[widget.activityList.first]?.timeSlots ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final total = calculateGrandTotal();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: const Color(0xFF4FBF26),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: showReview
            ? _buildReview(total)
            : _buildBookingForm(total),
      ),
    );
  }

  Widget _buildBookingForm(int total) {
    return ListView(
      children: [
        // Selection Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardStyle(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Selected Activities", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: widget.activityList.map((act) => Chip(
                  label: Text(act, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.green.shade100,
                )).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Date Picker
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardStyle(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select Date", style: TextStyle(fontWeight: FontWeight.bold)),
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
                          ? "Choose a date"
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

        // Time Selection
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardStyle(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select Time", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedTime.isEmpty ? null : selectedTime,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text('--- Select ---'),
                items: getAvailableTimeSlots()
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedTime = value!);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Visitors
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardStyle(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Visitors", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _counterRow("Domestic (Nepal)", domesticCount,
                  () => setState(() => domesticCount++), () => setState(() => domesticCount--)),
              _counterRow("SAARC Countries", saarcCount,
                  () => setState(() => saarcCount++), () => setState(() => saarcCount--)),
              _counterRow("Other Tourists", touristCount,
                  () => setState(() => touristCount++), () => setState(() => touristCount--)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Total
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardStyle(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text("Rs. $total", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4FBF26)),
            onPressed: total == 0 || selectedDate == null || selectedTime.isEmpty
                ? null
                : () => setState(() => showReview = true),
            child: const Text("Continue to Review", style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildReview(int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Booking Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _summaryRow("Activities", widget.activityList.join(", ")),
        _summaryRow("Date", DateFormat('yyyy-MM-dd').format(selectedDate!)),
        _summaryRow("Time", selectedTime),
        const Divider(height: 30, thickness: 1),
        const Text("Visitors", style: TextStyle(fontWeight: FontWeight.bold)),
        if (domesticCount > 0) _summaryRow("Domestic", "$domesticCount"),
        if (saarcCount > 0) _summaryRow("SAARC", "$saarcCount"),
        if (touristCount > 0) _summaryRow("Other Tourists", "$touristCount"),
        const Divider(height: 30, thickness: 1),
        _summaryRow("Total Amount", "Rs. $total"),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300),
                onPressed: () => setState(() => showReview = false),
                child: const Text("Edit", style: TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4FBF26)),
                onPressed: isSaving ? null : () => _saveToFirebase(total),
                child: isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text("Confirm & Pay", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- UI Helpers ---

  Widget _counterRow(String label, int count, VoidCallback onAdd, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.remove), onPressed: count > 0 ? onRemove : null),
              Text("$count", style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.add), onPressed: onAdd),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(width: 20),
          Expanded(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  BoxDecoration _cardStyle() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6)],
  );

  Future<void> pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }
}