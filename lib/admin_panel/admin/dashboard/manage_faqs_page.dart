import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageFAQsPage extends StatefulWidget {
  const ManageFAQsPage({super.key});

  @override
  State<ManageFAQsPage> createState() => _ManageFAQsPageState();
}

class _ManageFAQsPageState extends State<ManageFAQsPage> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  // Firestore logic to add or update
  Future<void> _saveFaq({String? docId}) async {
    final q = _questionController.text.trim();
    final a = _answerController.text.trim();

    if (q.isEmpty || a.isEmpty) return;

    final data = {
      "question": q,
      "answer": a,
      "timestamp": FieldValue.serverTimestamp(),
    };

    if (docId != null) {
      await FirebaseFirestore.instance.collection('faqs').doc(docId).update(data);
    } else {
      await FirebaseFirestore.instance.collection('faqs').add(data);
    }
    
    if (mounted) Navigator.pop(context);
  }

  void _showFaqDialog({String? docId, String? currentQ, String? currentA}) {
    _questionController.text = currentQ ?? "";
    _answerController.text = currentA ?? "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(docId != null ? "Edit FAQ" : "Add FAQ"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: "Question"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _answerController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: "Answer"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => _saveFaq(docId: docId),
            child: Text(docId != null ? "Update" : "Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage FAQs", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4FBF26),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('faqs').orderBy('timestamp').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String id = docs[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(data['question'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data['answer'] ?? ""),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showFaqDialog(
                          docId: id, 
                          currentQ: data['question'], 
                          currentA: data['answer']
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => FirebaseFirestore.instance.collection('faqs').doc(id).delete(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4FBF26),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showFaqDialog(),
      ),
    );
  }
}