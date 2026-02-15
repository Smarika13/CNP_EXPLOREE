import 'package:flutter/material.dart';

class ManageFAQsPage extends StatefulWidget {
  const ManageFAQsPage({super.key});

  @override
  State<ManageFAQsPage> createState() => _ManageFAQsPageState();
}

class _ManageFAQsPageState extends State<ManageFAQsPage> {
  // Preloaded FAQs from your FAQsPage
  List<Map<String, String>> faqs = [
    {
      "question": "When is the best time to visit?",
      "answer":
      "The best time is October to December for pleasant weather. "
          "For maximum wildlife sightings, late January to May is ideal "
          "as tall elephant grass is cut, improving visibility.",
    },
    {
      "question": "What are my chances of seeing a tiger?",
      "answer":
      "Tigers are elusive. The sighting success rate is around 20–30%. "
          "Your best chance is a full-day jeep safari during dry months "
          "(March–May) when tigers visit waterholes.",
    },
    {
      "question": "Are there still wild elephants in the park?",
      "answer":
      "Yes, but they are fewer and more dangerous than rhinos. "
          "Most elephants you see are domestic, though wild bulls "
          "occasionally enter the park and villages.",
    },
    {
      "question": "Do I really need a guide?",
      "answer":
      "Yes. A guide is mandatory by law. You cannot enter the core "
          "jungle alone. For jungle walks, a minimum of two guides "
          "is required for safety.",
    },
    {
      "question": "How much is the entry fee?",
      "answer":
      "As of 2026:\n"
          "• Foreigners: NPR 2,000\n"
          "• SAARC nationals: NPR 1,000\n"
          "• Nepalis: NPR 150",
    },
    {
      "question": "Can I use the same permit for two days?",
      "answer":
      "No. Permits are valid for a single entry on a single day "
          "(sunrise to sunset). A new permit is required for the next day.",
    },
    {
      "question": "Is a jungle walk safe?",
      "answer":
      "It is a calculated risk. Guides are trained for encounters, "
          "but animals like rhinos and bears are unpredictable. "
          "Most visitors find it the most thrilling experience.",
    },
    {
      "question": "What should I wear?",
      "answer":
      "Wear neutral colors such as olive, khaki, and brown. "
          "Avoid white, red, and yellow as they can provoke animals "
          "or make you too visible.",
    },
  ];

  // Controllers for adding/editing FAQs
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  // Add or edit FAQ
  void _showFaqDialog({Map<String, String>? faq, int? index}) {
    if (faq != null) {
      _questionController.text = faq['question']!;
      _answerController.text = faq['answer']!;
    } else {
      _questionController.clear();
      _answerController.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(faq != null ? "Edit FAQ" : "Add FAQ"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: "Question",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _answerController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Answer",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () {
                final q = _questionController.text.trim();
                final a = _answerController.text.trim();
                if (q.isEmpty || a.isEmpty) return;

                setState(() {
                  if (faq != null && index != null) {
                    faqs[index] = {"question": q, "answer": a};
                  } else {
                    faqs.add({"question": q, "answer": a});
                  }
                });
                Navigator.pop(context);
              },
              child: Text(faq != null ? "Update" : "Add")),
        ],
      ),
    );
  }

  // Delete FAQ
  void _deleteFaq(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete FAQ"),
        content: const Text("Are you sure you want to delete this FAQ?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  faqs.removeAt(index);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage FAQs"),
        backgroundColor: const Color(0xFF4FBF26),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF4F6F5),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(faq['question']!,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(faq['answer']!),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showFaqDialog(faq: faq, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteFaq(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4FBF26),
        child: const Icon(Icons.add),
        onPressed: () => _showFaqDialog(),
      ),
    );
  }
}
