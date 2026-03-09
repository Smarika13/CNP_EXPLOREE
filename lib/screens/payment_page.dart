import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../payment_services/esewa_mock_screen.dart';
import '../payment_services/khalti_mock_screen.dart';
import '../shared/services/guide_scheduler_service.dart';
import '../shared/services/notification_service.dart';
import 'payment_receipt_page.dart';

class PaymentPage extends StatefulWidget {
  final String activityName;
  final DateTime date;
  final String time;
  final int totalAmount;
  final String bookingId;
  final int groupSize;
  final String visitorName;

  const PaymentPage({
    super.key,
    required this.activityName,
    required this.date,
    required this.time,
    required this.totalAmount,
    required this.bookingId,
    required this.groupSize,
    required this.visitorName,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedMethod;
  bool isProcessing = false;

  final List<Map<String, String>> paymentMethods = [
    {"name": "Khalti", "image": "assets/images/khaltilogo.png"},
    {"name": "eSewa", "image": "assets/images/esewalogo.png"},
  ];

  String _toLocalNum(int n) {
    if (context.locale.languageCode != 'ne') return '$n';
    const digits = ['०','१','२','३','४','५','६','७','८','९'];
    return '$n'.split('').map((c) {
      final d = int.tryParse(c);
      return d != null ? digits[d] : c;
    }).join();
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

  String _translateTimeSlot(String slot) {
    switch (slot) {
      case '6–10 AM': return 'slot_morning'.tr();
      case '2–5 PM':  return 'slot_afternoon'.tr();
      case '7–8 PM':  return 'slot_evening'.tr();
      default: return slot;
    }
  }

  Future<void> _handlePayment() async {
    if (selectedMethod == null) return;

    bool? success;

    if (selectedMethod == 'Khalti') {
      success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => KhaltiMockScreen(amount: widget.totalAmount)),
      );
    } else {
      success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => EsewaMockScreen(amount: widget.totalAmount)),
      );
    }

    if (!mounted || success != true) return;

    setState(() => isProcessing = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => isProcessing = false);
    await _onPaymentSuccess();
  }

  Future<void> _onPaymentSuccess() async {
    final String txnId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
    setState(() => isProcessing = true);
    try {
      // 1. Update Firestore booking with payment info
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({
        'paymentMethod': selectedMethod ?? 'Unknown',
        'paymentStatus': 'Paid',
        'transactionId': txnId,
        'paidAt': FieldValue.serverTimestamp(),
      });

      // 2. Assign guide now that payment is confirmed
      await GuideSchedulerService().assignGuidesForBooking(
        bookingId: widget.bookingId,
        activities: [widget.activityName],
        date: DateFormat('yyyy-MM-dd').format(widget.date),
        timeSlot: widget.time,
        groupSize: widget.groupSize,
      );

      // 3. Save assigned guide info to booking for user notification
      await _saveGuideInfoToBooking();

      // 4. Notify assigned guides via email
      await _notifyAssignedGuides();

      // 4. Send receipt email to user
      final user = FirebaseAuth.instance.currentUser;
      if (user?.email != null) {
        await NotificationService.sendUserReceipt(
          userEmail: user!.email!,
          userName: widget.visitorName,
          activity: widget.activityName,
          date: DateFormat('yyyy-MM-dd').format(widget.date),
          timeSlot: widget.time,
          groupSize: widget.groupSize,
          totalAmount: widget.totalAmount,
          paymentMethod: selectedMethod ?? '',
          transactionId: txnId,
          bookingId: widget.bookingId,
        );
      }
    } catch (e) {
      debugPrint('[Payment] Post-payment update failed: $e');
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentReceiptPage(
          activityName: widget.activityName,
          date: widget.date,
          timeSlot: widget.time,
          groupSize: widget.groupSize,
          totalAmount: widget.totalAmount,
          paymentMethod: selectedMethod ?? '',
          transactionId: txnId,
          bookingId: widget.bookingId,
          visitorName: widget.visitorName,
        ),
      ),
    );
  }

  Future<void> _saveGuideInfoToBooking() async {
    try {
      final slotsSnap = await FirebaseFirestore.instance
          .collection('guide_slots')
          .where('bookingIds', arrayContains: widget.bookingId)
          .get();

      // Collect unique guide IDs assigned to this booking
      final seenGuideIds = <String>{};
      for (final doc in slotsSnap.docs) {
        final data = doc.data();
        if ((data['slotType'] as String? ?? '') != 'guide') continue;
        final gId = data['guideId'] as String? ?? '';
        if (gId.isNotEmpty) seenGuideIds.add(gId);
      }

      if (seenGuideIds.isEmpty) return;

      // Fetch each guide doc and build list
      final guides = <Map<String, String>>[];
      for (final gId in seenGuideIds) {
        final guideDoc = await FirebaseFirestore.instance
            .collection('guides')
            .doc(gId)
            .get();
        if (!guideDoc.exists) continue;
        final d = guideDoc.data()!;
        guides.add({
          'name':  d['name']  as String? ?? '',
          'phone': d['phone'] as String? ?? '',
          'email': d['email'] as String? ?? '',
        });
      }

      if (guides.isEmpty) return;

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({
        // Keep legacy single-guide fields for backward compat
        'guideName':  guides.first['name'],
        'guidePhone': guides.first['phone'],
        'guideEmail': guides.first['email'],
        // New: full list for multiple guides
        'assignedGuides': guides,
      });
    } catch (e) {
      debugPrint('[Payment] Failed to save guide info: $e');
    }
  }

  Future<void> _notifyAssignedGuides() async {
    try {
      final slotsSnap = await FirebaseFirestore.instance
          .collection('guide_slots')
          .where('bookingIds', arrayContains: widget.bookingId)
          .get();

      final Set<String> notified = {};
      for (final slotDoc in slotsSnap.docs) {
        if ((slotDoc.data()['slotType'] as String? ?? '') != 'guide') continue;
        final guideId = slotDoc.data()['guideId'] as String? ?? '';
        if (guideId.isEmpty || notified.contains(guideId)) continue;
        notified.add(guideId);
        await NotificationService.notifyGuide(
          guideId: guideId,
          bookingId: widget.bookingId,
          activity: widget.activityName,
          date: DateFormat('yyyy-MM-dd').format(widget.date),
          timeSlot: widget.time,
          groupSize: widget.groupSize,
          visitorName: widget.visitorName,
        );
      }
    } catch (e) {
      debugPrint('[Payment] Guide notification failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: Text('payment_title'.tr()),
        backgroundColor: const Color(0xFF4FBF26),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Text(_translatedActivityName(widget.activityName),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("${DateFormat('MMM d, yyyy').format(widget.date)} | ${_translateTimeSlot(widget.time)}"),
                  const Divider(height: 24),
                  Text('payment_total_payable'.tr(), style: const TextStyle(color: Colors.grey)),
                  Text("${'currency'.tr()} ${_toLocalNum(widget.totalAmount)}",
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text('payment_select_method'.tr(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ...paymentMethods.map((method) {
              bool isSelected = selectedMethod == method["name"];
              return GestureDetector(
                onTap: () => setState(() => selectedMethod = method["name"]),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isSelected ? Colors.green : Colors.transparent, width: 2),
                  ),
                  child: ListTile(
                    leading: Image.asset(method["image"]!, width: 40, height: 40,
                        errorBuilder: (c, e, s) => const Icon(Icons.payment)),
                    title: Text(method["name"]!,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Radio<String>(
                      value: method["name"]!,
                      groupValue: selectedMethod,
                      activeColor: Colors.green,
                      onChanged: (value) => setState(() => selectedMethod = value),
                    ),
                  ),
                ),
              );
            }),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (selectedMethod == null || isProcessing) ? null : _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FBF26),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isProcessing
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text('payment_confirm_pay'.tr(),
                        style: const TextStyle(
                            color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
