import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PublishNewsPage extends StatefulWidget {
  const PublishNewsPage({super.key});

  @override
  State<PublishNewsPage> createState() => _PublishNewsPageState();
}

class _PublishNewsPageState extends State<PublishNewsPage> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final CollectionReference _newsCollection = FirebaseFirestore.instance.collection('news');

  // --- SHOW DIALOG (ADD OR EDIT) ---
  void _showNewsDialog({String? docId, String? existingTitle, String? existingSubtitle}) {
    if (docId != null) {
      _titleController.text = existingTitle!;
      _subtitleController.text = existingSubtitle!;
    } else {
      _titleController.clear();
      _subtitleController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(docId == null ? "Add News" : "Edit News"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _subtitleController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Description/Subtitle", border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4FBF26)),
            onPressed: () => _handleFirebaseAction(docId),
            child: Text(docId == null ? "Add" : "Update", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- FIREBASE ACTIONS (CREATE / UPDATE) ---
  Future<void> _handleFirebaseAction(String? docId) async {
    final title = _titleController.text.trim();
    final subtitle = _subtitleController.text.trim();
    if (title.isEmpty || subtitle.isEmpty) return;

    if (docId == null) {
      // Create new document
      await _newsCollection.add({
        'title': title,
        'subtitle': subtitle,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // Update existing document
      await _newsCollection.doc(docId).update({
        'title': title,
        'subtitle': subtitle,
      });
    }

    if (mounted) Navigator.pop(context);
  }

  // --- DELETE NEWS ---
  void _deleteNews(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete News"),
        content: const Text("Remove this update from the customer app?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await _newsCollection.doc(docId).delete();
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Publish News (Admin)", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4FBF26),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showNewsDialog(),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF4F6F5),
      body: StreamBuilder<QuerySnapshot>(
        // Streaming data from Firebase sorted by newest first
        stream: _newsCollection.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) return const Center(child: Text("No news published yet."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF4FBF26),
                    child: Icon(Icons.newspaper, color: Colors.white, size: 20),
                  ),
                  title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data['subtitle'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showNewsDialog(
                          docId: docId,
                          existingTitle: data['title'],
                          existingSubtitle: data['subtitle'],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteNews(docId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}