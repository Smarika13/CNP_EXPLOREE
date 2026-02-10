import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentPage extends StatefulWidget {
  final String activityName;
  final DateTime date;
  final String time;
  final int totalAmount;

  const PaymentPage({
    super.key,
    required this.activityName,
    required this.date,
    required this.time,
    required this.totalAmount,
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

  // Logic to handle the payment button click
  void _handlePayment() async {
    setState(() => isProcessing = true);

    // Simulate network delay for payment gateway
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Show Success Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Booking Confirmed!",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Text("Payment of Rs. ${widget.totalAmount} via $selectedMethod successful."),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4FBF26)),
              onPressed: () {
                // Return to Home Screen (removes all previous screens)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("Go to Home", style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
    
    setState(() => isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: const Color(0xFF4FBF26),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
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
                  Text(widget.activityName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("${DateFormat('MMM d, yyyy').format(widget.date)} | ${widget.time}"),
                  const Divider(height: 24),
                  const Text("Total Payable", style: TextStyle(color: Colors.grey)),
                  Text("Rs. ${widget.totalAmount}", 
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            const Text("Select Payment Method", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Payment Options
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
                    border: Border.all(color: isSelected ? Colors.green : Colors.transparent, width: 2),
                  ),
                  child: ListTile(
                    leading: Image.asset(method["image"]!, width: 40, height: 40, errorBuilder: (c, e, s) => const Icon(Icons.payment)),
                    title: Text(method["name"]!, style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Radio<String>(
                      value: method["name"]!,
                      groupValue: selectedMethod,
                      activeColor: Colors.green,
                      onChanged: (value) => setState(() => selectedMethod = value),
                    ),
                  ),
                ),
              );
            }).toList(),

            const Spacer(),

            // Action Button
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
                    : const Text("Confirm & Pay", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}