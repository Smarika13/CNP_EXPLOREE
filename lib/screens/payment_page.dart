import 'package:flutter/material.dart';

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

  final List<Map<String, String>> paymentMethods = [
    {"name": "Khalti", "image": "assets/images/khaltilogo.png"},
    {"name": "eSewa", "image": "assets/images/esewalogo.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text("Select Payment Method"),
        backgroundColor: const Color(0xFF4FBF26),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Choose your payment method",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Payment options
            ...paymentMethods.map((method) {
              bool isSelected = selectedMethod == method["name"];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMethod = method["name"];
                  });
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.green : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  child: ListTile(
                    leading: Image.asset(
                      method["image"]!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                    title: Text(
                      method["name"]!,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    trailing: Radio<String>(
                      value: method["name"]!,
                      groupValue: selectedMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedMethod = value;
                        });
                      },
                    ),
                  ),
                ),
              );
            }).toList(),

            const Spacer(),

            // Pay button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedMethod == null
                    ? null
                    : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Proceeding with $selectedMethod for payment of Rs. ${widget.totalAmount}"),
                    ),
                  );
                  // TODO: Integrate Khalti or eSewa SDK here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FBF26),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: const Text(
                  "Pay Now",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
