import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates

class BookingDetailPage extends StatelessWidget {
  final Map<String, dynamic> booking;
  final int totalAmount;

  const BookingDetailPage({
    super.key,
    required this.booking,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy');
    final bookedOn = booking.containsKey('bookedOn')
        ? formatter.format(DateTime.parse(booking['bookedOn']))
        : booking['date']; // fallback to original date
    final bookedFor = booking.containsKey('bookedFor')
        ? formatter.format(DateTime.parse(booking['bookedFor']))
        : booking['date'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: Colors.green,
      ),
      backgroundColor: const Color(0xFFF4F6F5),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Basic Info =====
              _row("Activity", booking['activity'] as String),
              _row("User", booking['user'] as String),
              _row("Booked On", bookedOn),
              _row("Booked For", "$bookedFor (${booking['time']})"),

              const SizedBox(height: 16),

              // ===== Booking Type Section =====
              const Text(
                "Booking Type & Visitors",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Static values for now
              _row("Domestic Visitors (x1)", "Rs. 1650"),
              _row("SAARC Visitors (x1)", "Rs. 4000"),

              const Divider(height: 24),

              // ===== Total =====
              _row(
                "Total Amount",
                "Rs. $totalAmount",
                isBold: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Reusable Row Widget =====
  Widget _row(String left, String right, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: const TextStyle(fontSize: 14)),
          Text(
            right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
