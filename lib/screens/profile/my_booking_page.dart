import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyBookingPage extends StatelessWidget {
  const MyBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text("My Bookings", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B5E20),
        centerTitle: true,
      ),
      body: userId == null
          ? const Center(child: Text("Please login first"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('userId', isEqualTo: userId)
                  .orderBy('bookingTimestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF4FBF26)));
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text("No bookings yet.",
                            style: TextStyle(color: Colors.black54, fontSize: 15)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    // activity is stored as single string
                    final String activity = data['activity'] ?? data['activityName'] ?? 'Unknown Activity';
                    final String date = data['date'] ?? '';
                    final String time = data['time'] ?? '';
                    final int totalAmount = (data['totalAmount'] as num?)?.toInt() ?? 0;
                    final String paymentStatus = data['paymentStatus'] ?? 'Pending';
                    final String paymentMethod = data['paymentMethod'] ?? '';
                    final String transactionId = data['transactionId'] ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header strip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: const BoxDecoration(
                              color: Color(0xFF4FBF26),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    activity,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                _paymentBadge(paymentStatus),
                              ],
                            ),
                          ),

                          // Details
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              children: [
                                _row(Icons.calendar_today_outlined, 'Date', date),
                                _row(Icons.access_time, 'Time Slot', time),
                                _row(Icons.payments_outlined, 'Amount',
                                    'Rs. $totalAmount',
                                    valueColor: Colors.green,
                                    bold: true),
                                if (paymentMethod.isNotEmpty)
                                  _row(Icons.account_balance_wallet_outlined, 'Paid via', paymentMethod),
                                if (transactionId.isNotEmpty)
                                  _row(Icons.receipt_long_outlined, 'Txn ID', transactionId,
                                      valueColor: Colors.grey.shade600, small: true),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _row(IconData icon, String label, String value,
      {Color? valueColor, bool bold = false, bool small = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF4FBF26)),
          const SizedBox(width: 8),
          Text('$label: ',
              style: TextStyle(fontSize: small ? 12 : 13, color: Colors.grey.shade600)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: small ? 11 : 13,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                color: valueColor,
                fontFamily: small ? 'monospace' : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentBadge(String status) {
    final isPaid = status == 'Paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? Colors.white : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPaid ? '✓ Paid' : 'Pending',
        style: TextStyle(
          color: isPaid ? const Color(0xFF2e7d32) : Colors.orange.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
