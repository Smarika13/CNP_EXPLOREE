import 'package:flutter/material.dart';

class FAQsPage extends StatelessWidget {
  const FAQsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text("FAQs"),
        backgroundColor: const Color(0xFF4FBF26),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          FaqTile(
            question: "When is the best time to visit?",
            answer:
            "The best time is October to December for pleasant weather. "
                "For maximum wildlife sightings, late January to May is ideal "
                "as tall elephant grass is cut, improving visibility.",
          ),
          FaqTile(
            question: "What are my chances of seeing a tiger?",
            answer:
            "Tigers are elusive. The sighting success rate is around 20–30%. "
                "Your best chance is a full-day jeep safari during dry months "
                "(March–May) when tigers visit waterholes.",
          ),
          FaqTile(
            question: "Are there still wild elephants in the park?",
            answer:
            "Yes, but they are fewer and more dangerous than rhinos. "
                "Most elephants you see are domestic, though wild bulls "
                "occasionally enter the park and villages.",
          ),
          FaqTile(
            question: "Do I really need a guide?",
            answer:
            "Yes. A guide is mandatory by law. You cannot enter the core "
                "jungle alone. For jungle walks, a minimum of two guides "
                "is required for safety.",
          ),
          FaqTile(
            question: "How much is the entry fee?",
            answer:
            "As of 2026:\n"
                "• Foreigners: NPR 2,000\n"
                "• SAARC nationals: NPR 1,000\n"
                "• Nepalis: NPR 150",
          ),
          FaqTile(
            question: "Can I use the same permit for two days?",
            answer:
            "No. Permits are valid for a single entry on a single day "
                "(sunrise to sunset). A new permit is required for the next day.",
          ),
          FaqTile(
            question: "Is a jungle walk safe?",
            answer:
            "It is a calculated risk. Guides are trained for encounters, "
                "but animals like rhinos and bears are unpredictable. "
                "Most visitors find it the most thrilling experience.",
          ),
          FaqTile(
            question: "What should I wear?",
            answer:
            "Wear neutral colors such as olive, khaki, and brown. "
                "Avoid white, red, and yellow as they can provoke animals "
                "or make you too visible.",
          ),
        ],
      ),
    );
  }
}

class FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const FaqTile({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: [
          Text(
            answer,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
