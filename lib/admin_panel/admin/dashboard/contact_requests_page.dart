import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactRequestsPage extends StatelessWidget {
  const ContactRequestsPage({super.key});

  // ===== Email Launch Function =====
  Future<void> _openEmail(
      BuildContext context, String email, String name, String subject) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Re: $subject',
        'body': 'Hello $name,\n\n',
      },
    );

    try {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open email app.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text("Contact Requests", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      // Real-time stream listening to the 'contact_requests' collection
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('contact_requests')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error loading data"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No inquiries received yet.", 
              style: TextStyle(color: Colors.grey, fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    data['subject'] ?? 'No Subject',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Text("From: ${data['name']}"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showDetails(context, data, docId),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDetails(BuildContext context, Map<String, dynamic> data, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(data['subject'] ?? 'Inquiry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("From: ${data['name']}", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Email: ${data['email']}"),
            const Divider(height: 16),
            Text(data['message'] ?? 'No message content available.'),
          ],
        ),
        actions: [
          // Remove the request from Firestore once handled
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('contact_requests').doc(docId).delete();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Resolve & Delete", style: TextStyle(color: Colors.red)),
          ),
          // Launch email app with pre-filled details
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              _openEmail(context, data['email'] ?? '', data['name'] ?? 'User', data['subject'] ?? 'Inquiry');
            },
            child: const Text("Reply", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}