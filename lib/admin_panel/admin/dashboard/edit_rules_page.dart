import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditRulesPage extends StatefulWidget {
  const EditRulesPage({super.key});

  @override
  State<EditRulesPage> createState() => _EditRulesPageState();
}

class _EditRulesPageState extends State<EditRulesPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> sections = [
    "Inside the Jungle",
    "Safety Measures Inside Jungle",
    "Outside the Jungle",
    "Safety Measures Outside Jungle"
  ];

  // Save or Update Rule in Firestore
  Future<void> _saveRule(String section, {String? docId}) async {
    if (_controller.text.trim().isEmpty) return;

    final data = {
      "section": section,
      "text": _controller.text.trim(),
      "timestamp": FieldValue.serverTimestamp(),
    };

    if (docId != null) {
      await FirebaseFirestore.instance.collection('park_rules').doc(docId).update(data);
    } else {
      await FirebaseFirestore.instance.collection('park_rules').add(data);
    }
    if (mounted) Navigator.pop(context);
  }

  void _showRuleDialog(String section, {String? docId, String? existingText}) {
    _controller.text = existingText ?? "";
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(docId == null ? "Add Rule to $section" : "Edit Rule"),
        content: TextField(
          controller: _controller,
          maxLines: 3,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => _saveRule(section, docId: docId),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Rules"), backgroundColor: const Color(0xFF4FBF26)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('park_rules').orderBy('timestamp').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // Grouping rules by section locally for display
          Map<String, List<QueryDocumentSnapshot>> groupedRules = {};
          for (var sec in sections) {
            groupedRules[sec] = snapshot.data!.docs.where((d) => d['section'] == sec).toList();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: sections.map((section) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(section, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, 
                          color: section.contains("Safety") ? Colors.redAccent : Colors.green)),
                      IconButton(icon: const Icon(Icons.add_circle, color: Colors.blue), 
                          onPressed: () => _showRuleDialog(section)),
                    ],
                  ),
                  ...groupedRules[section]!.map((doc) => Card(
                    child: ListTile(
                      title: Text(doc['text']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, size: 20), 
                              onPressed: () => _showRuleDialog(section, docId: doc.id, existingText: doc['text'])),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), 
                              onPressed: () => FirebaseFirestore.instance.collection('park_rules').doc(doc.id).delete()),
                        ],
                      ),
                    ),
                  )),
                  const Divider(height: 30),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}