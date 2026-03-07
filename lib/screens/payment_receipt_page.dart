import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentReceiptPage extends StatelessWidget {
  final String activityName;
  final DateTime date;
  final String timeSlot;
  final int groupSize;
  final int totalAmount;
  final String paymentMethod;
  final String transactionId;
  final String bookingId;
  final String visitorName;

  const PaymentReceiptPage({
    super.key,
    required this.activityName,
    required this.date,
    required this.timeSlot,
    required this.groupSize,
    required this.totalAmount,
    required this.paymentMethod,
    required this.transactionId,
    required this.bookingId,
    required this.visitorName,
  });

  bool get _isEsewa => paymentMethod == 'eSewa';

  Color get _brandColor =>
      _isEsewa ? const Color(0xFF4FBF26) : const Color(0xFF5C2D91);

  String get _logoAsset => _isEsewa
      ? 'assets/images/esewalogo.png'
      : 'assets/images/khaltilogo.png';

  Widget _row(String label, String value,
      {Color? valueColor, bool bold = false, bool copyable = false, BuildContext? ctx}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ),
          Expanded(
            child: GestureDetector(
              onTap: copyable && ctx != null
                  ? () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                            content: Text('Copied!'),
                            duration: Duration(seconds: 1)),
                      );
                    }
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                        color: valueColor,
                      ),
                    ),
                  ),
                  if (copyable) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.copy, size: 13, color: Colors.grey.shade400),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = _brandColor;

    return Scaffold(
      backgroundColor: brand,
      appBar: AppBar(
        backgroundColor: brand,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(_logoAsset, width: 26, height: 26,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.payment, color: Colors.white)),
            const SizedBox(width: 8),
            Text(paymentMethod,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Top success banner ───────────────────────────────────────────
          Container(
            width: double.infinity,
            color: brand,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle,
                      color: Colors.white, size: 48),
                ),
                const SizedBox(height: 10),
                const Text('Payment Successful!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Rs. $totalAmount',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                    DateFormat('MMM d, yyyy · hh:mm a')
                        .format(DateTime.now()),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),

          // ── Receipt card ─────────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7F5),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Status pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified,
                              size: 14, color: Colors.green.shade700),
                          const SizedBox(width: 6),
                          Text('Booking Confirmed',
                              style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // QR code ticket
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.qr_code_2,
                                  size: 16, color: brand),
                              const SizedBox(width: 6),
                              Text('Entry QR Code',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: brand)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          QrImageView(
                            data: bookingId,
                            version: QrVersions.auto,
                            size: 160,
                            eyeStyle: QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: brand,
                            ),
                            dataModuleStyle: QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: brand,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Show this at the park entrance',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Booking details card
                    _card(
                      title: 'Booking Details',
                      icon: Icons.event_note,
                      color: brand,
                      children: [
                        _row('Activity', activityName, bold: true),
                        _divider(),
                        _row('Date',
                            DateFormat('MMM d, yyyy').format(date)),
                        _divider(),
                        _row('Time Slot', timeSlot),
                        _divider(),
                        _row('Visitors', '$groupSize person${groupSize > 1 ? 's' : ''}'),
                        _divider(),
                        _row('Guest Name', visitorName),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Payment details card
                    _card(
                      title: 'Payment Details',
                      icon: Icons.receipt_long,
                      color: brand,
                      children: [
                        _row('Method', paymentMethod),
                        _divider(),
                        _row('Amount Paid', 'Rs. $totalAmount',
                            valueColor: Colors.green,
                            bold: true),
                        _divider(),
                        _row('Status', 'Successful ✓',
                            valueColor: Colors.green, bold: true),
                        _divider(),
                        _row('Transaction ID', transactionId,
                            valueColor: Colors.grey.shade600,
                            copyable: true,
                            ctx: context),
                        _divider(),
                        _row('Booking ID', bookingId,
                            valueColor: Colors.grey.shade600,
                            copyable: true,
                            ctx: context),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Info note
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.mail_outline,
                              size: 18, color: Colors.blue.shade700),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'A receipt has been sent to your registered email address.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Go Home button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.home_outlined,
                            color: Colors.white),
                        label: const Text('Go to Home',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brand,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 12, color: Colors.grey.shade200);

  Widget _card({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: color)),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
