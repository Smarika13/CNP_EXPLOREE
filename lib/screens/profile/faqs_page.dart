import 'package:flutter/material.dart';

class FAQsPage extends StatelessWidget {
  const FAQsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {"q": "How do I book a service?", "a": "Navigate to the home screen and select a service."},
      {"q": "Can I cancel my booking?", "a": "Yes, via 'My Bookings' up to 24 hours before."},
      {"q": "What payment methods are accepted?", "a": "Esewa, Khalti, and Cash on Delivery."},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("FAQs", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: faqs.length,
                itemBuilder: (context, index) { 
                  return ExpansionTile(
                    title: Text(faqs[index]["q"]!),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(faqs[index]["a"]!),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}