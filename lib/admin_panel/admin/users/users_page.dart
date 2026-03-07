import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('users')
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text('Users'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs
              .where((d) {
                final data = d.data() as Map<String, dynamic>;
                return (data['role'] ?? 'user') == 'user';
              })
              .toList()
            ..sort((a, b) {
              final ta = (a.data() as Map)['createdAt'] as Timestamp?;
              final tb = (b.data() as Map)['createdAt'] as Timestamp?;
              if (ta == null && tb == null) return 0;
              if (ta == null) return 1;
              if (tb == null) return -1;
              return tb.compareTo(ta);
            });

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 56, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No users yet.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Total Users: ${docs.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final name = data['fullName'] ??
                        '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
                    final email = data['email'] ?? '';

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _UserDetailPage(data: data),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 6)
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: const Icon(Icons.person, color: Colors.white, size: 25),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name.isEmpty ? 'Unknown' : name,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  if (email.isNotEmpty)
                                    Text(
                                      email,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.black38),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UserDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;
  const _UserDetailPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['fullName'] ??
        '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
    final email = data['email'] ?? '—';
    final role = data['role'] ?? '—';
    final Timestamp? ts = data['createdAt'];
    final joinedOn = ts != null
        ? DateFormat('MMM d, yyyy').format(ts.toDate())
        : '—';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text('User Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child:
                  const Icon(Icons.person, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 8),
            Text(
              name.isEmpty ? 'Unknown' : name,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row(context, Icons.person, 'Full Name',
                        name.isEmpty ? '—' : name),
                    const Divider(height: 1),
                    _row(context, Icons.email, 'Email', email),
                    const Divider(height: 1),
                    _row(context, Icons.badge, 'Role', role),
                    const Divider(height: 1),
                    _row(context, Icons.calendar_today, 'Joined', joinedOn),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(label,
                style:
                    const TextStyle(fontSize: 13, color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
