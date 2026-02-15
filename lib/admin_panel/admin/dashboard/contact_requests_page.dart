import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactRequestsPage extends StatelessWidget {
  const ContactRequestsPage({super.key});

  // Example contact requests (later you will fetch from Firebase/backend)
  final List<Map<String, String>> contactRequests = const [
    {
      "name": "Sudikshya",
      "email": "sudikshya@example.com",
      "subject": "Booking Inquiry",
      "message": "Hello, I want to know if I can book a jeep safari for next weekend."
    },
    {
      "name": "Ramesh",
      "email": "ramesh@example.com",
      "subject": "Park Rules",
      "message": "Can you tell me the rules for jungle walks?"
    },
    {
      "name": "Sita",
      "email": "sita@example.com",
      "subject": "Payment Issue",
      "message": "I paid for the elephant safari but did not receive a confirmation."
    },
  ];

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
      await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open email app.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text("Contact Requests"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contactRequests.length,
        itemBuilder: (context, index) {
          final request = contactRequests[index];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Text(
                request['subject']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                "From: ${request['name']}",
                style: const TextStyle(fontSize: 13),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(request['subject']!),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("From: ${request['name']}"),
                        const SizedBox(height: 4),
                        Text("Email: ${request['email']}"),
                        const Divider(height: 16),
                        Text(request['message']!),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () {
                          _openEmail(
                            context,
                            request['email']!,
                            request['name']!,
                            request['subject']!,
                          );
                        },
                        child: const Text("Reply"),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
