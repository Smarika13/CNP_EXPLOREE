import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManageGuidesPage extends StatelessWidget {
  const ManageGuidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text('Manage Guides'),
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Guide'),
        onPressed: () => _showGuideDialog(context, null, null),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('guides')
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('No guides yet.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B4332)),
                    icon: const Icon(Icons.person_add, color: Colors.white),
                    label: const Text('Add First Guide',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () => _showGuideDialog(context, null, null),
                  ),
                ],
              ),
            );
          }

          // Sort client-side by createdAt (FCFS). Guides without createdAt go last.
          final docs = [...snap.data!.docs]..sort((a, b) {
            final aTs = (a.data() as Map)['createdAt'] as Timestamp?;
            final bTs = (b.data() as Map)['createdAt'] as Timestamp?;
            if (aTs == null && bTs == null) return 0;
            if (aTs == null) return 1;
            if (bTs == null) return -1;
            return aTs.compareTo(bTs);
          });
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _GuideCard(doc: docs[i]),
          );
        },
      ),
    );
  }

  static void _showGuideDialog(
    BuildContext context,
    String? docId,
    Map<String, dynamic>? existing,
  ) {
    final existingName = (existing?['name'] ?? '').toString().trim().split(RegExp(r'\s+'));
    final firstNameCtrl = TextEditingController(text: existingName.isNotEmpty ? existingName.first : '');
    final lastNameCtrl  = TextEditingController(text: existingName.length > 1 ? existingName.skip(1).join(' ') : '');
    final phoneCtrl = TextEditingController(text: existing?['phone'] ?? '');
    final emailCtrl = TextEditingController(text: existing?['email'] ?? '');
    final formKey   = GlobalKey<FormState>();
    final isEdit    = docId != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Guide' : 'Add New Guide'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: firstNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (v.trim().length < 2) return 'Too short';
                          if (!RegExp(r"^[a-zA-Z'-]+$").hasMatch(v.trim())) return 'Letters only';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: lastNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (v.trim().length < 2) return 'Too short';
                          if (!RegExp(r"^[a-zA-Z'-]+$").hasMatch(v.trim())) return 'Letters only';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    hintText: '98XXXXXXXX',
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Phone number is required';
                    final digits = v.trim().replaceAll(RegExp(r'\D'), '');
                    if (digits.length != 10) return 'Must be exactly 10 digits';
                    if (!RegExp(r'^(98|97|96)[0-9]{8}$').hasMatch(digits)) {
                      return 'Enter a valid Nepali mobile number (98/97/96XXXXXXXX)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    final valid = RegExp(
                      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
                    ).hasMatch(v.trim());
                    if (!valid) return 'Enter a valid email address';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B4332)),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              final data = {
                'name': '${firstNameCtrl.text.trim()} ${lastNameCtrl.text.trim()}',
                'phone': phoneCtrl.text.trim(),
                'email': emailCtrl.text.trim().toLowerCase(),
              };
              if (isEdit) {
                await FirebaseFirestore.instance
                    .collection('guides')
                    .doc(docId)
                    .update(data);
              } else {
                await FirebaseFirestore.instance.collection('guides').add({
                  ...data,
                  'isActive': true,
                  'totalAssignments': 0,
                  'createdAt': FieldValue.serverTimestamp(),
                });
              }
            },
            child: Text(
              isEdit ? 'Save' : 'Add',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const _GuideCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] as String? ?? 'Unknown';
    final phone = data['phone'] as String? ?? '—';
    final email = data['email'] as String? ?? '';
    final isActive = data['isActive'] as bool? ?? true;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.hardEdge,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor:
                isActive ? const Color(0xFFE8F5E9) : Colors.grey.shade200,
            child: Icon(
              Icons.person,
              color: isActive ? const Color(0xFF1B4332) : Colors.grey,
            ),
          ),
          title: Text(name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(phone,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.black54)),
              if (email.isNotEmpty)
                Text(email,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.black45)),
              const SizedBox(height: 4),
              Row(
                children: [
                  _statusBadge(isActive),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FutureBuilder<int>(
                      future: _liveAssignmentCount(),
                      builder: (context, snap) {
                        final count = snap.data ?? 0;
                        final label = snap.connectionState == ConnectionState.waiting
                            ? '— assignments  •  tap to view'
                            : '$count assignment${count == 1 ? '' : 's'}  •  tap to view';
                        return Text(
                          label,
                          style: const TextStyle(fontSize: 11, color: Colors.black45),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) => _handleAction(context, value, data),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(
                value: 'toggle',
                child: Text(isActive ? 'Set Inactive' : 'Set Active'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child:
                    Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          children: [
            _AssignmentsList(guideId: doc.id),
          ],
        ),
      ),
    );
  }

  Future<int> _liveAssignmentCount() async {
    final snap = await FirebaseFirestore.instance
        .collection('guide_slots')
        .where('guideId', isEqualTo: doc.id)
        .get();
    return snap.docs.length;
  }

  Widget _statusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.green.shade800 : Colors.grey.shade600,
        ),
      ),
    );
  }

  Future<bool> _hasAssignments() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final snap = await FirebaseFirestore.instance
        .collection('guide_slots')
        .where('guideId', isEqualTo: doc.id)
        .get();
    return snap.docs.any((d) {
      final date = (d.data() as Map)['date'] as String? ?? '';
      return date.compareTo(today) >= 0;
    });
  }

  void _showBlockedDialog(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(Icons.lock_outlined, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 8),
          const Text('Not Allowed'),
        ]),
        content: Text(
          'This guide has upcoming assignments. '
          'You cannot ${action == 'toggle' ? 'set them inactive' : 'delete them'} '
          'while they are assigned to future bookings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleAction(
      BuildContext context, String action, Map<String, dynamic> data) {
    final isActive = data['isActive'] as bool? ?? true;

    switch (action) {
      case 'edit':
        ManageGuidesPage._showGuideDialog(context, doc.id, data);
        break;

      case 'toggle':
        if (!isActive) {
          // Re-activating is always allowed
          FirebaseFirestore.instance
              .collection('guides')
              .doc(doc.id)
              .update({'isActive': true});
        } else {
          // Deactivating: block if guide has assignments
          _hasAssignments().then((hasAsgn) {
            if (hasAsgn) {
              _showBlockedDialog(context, 'toggle');
            } else {
              FirebaseFirestore.instance
                  .collection('guides')
                  .doc(doc.id)
                  .update({'isActive': false});
            }
          });
        }
        break;

      case 'delete':
        _hasAssignments().then((hasAsgn) {
          if (hasAsgn) {
            _showBlockedDialog(context, 'delete');
            return;
          }
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Remove Guide'),
              content: Text(
                  'Remove "${data['name']}" from the guide list? This cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    // Delete all past guide_slots for this guide before removing
                    final slotsSnap = await FirebaseFirestore.instance
                        .collection('guide_slots')
                        .where('guideId', isEqualTo: doc.id)
                        .get();
                    if (slotsSnap.docs.isNotEmpty) {
                      final slotBatch = FirebaseFirestore.instance.batch();
                      for (final s in slotsSnap.docs) {
                        slotBatch.delete(s.reference);
                      }
                      await slotBatch.commit();
                    }
                    await FirebaseFirestore.instance
                        .collection('guides')
                        .doc(doc.id)
                        .delete();
                  },
                  child: const Text('Remove',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        });
        break;
    }
  }
}

class _AssignmentsList extends StatelessWidget {
  final String guideId;
  const _AssignmentsList({required this.guideId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('guide_slots')
          .where('guideId', isEqualTo: guideId)
          .get(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final slots = [...(snap.data?.docs ?? [])]..sort((a, b) {
            final aDate = (a.data() as Map)['date'] as String? ?? '';
            final bDate = (b.data() as Map)['date'] as String? ?? '';
            return bDate.compareTo(aDate); // newest first
          });

        if (slots.isEmpty) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Text('No assignments yet.',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 16),
              const Text('Assignments',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1B4332))),
              const SizedBox(height: 8),
              ...slots.map((slot) {
                final d = slot.data() as Map<String, dynamic>;
                final activity = d['activityId'] as String? ?? '—';
                final date = d['date'] as String? ?? '—';
                final time = d['timeSlot'] as String? ?? '—';
                final filled = d['filledSeats'] as int? ?? 0;
                final max = d['maxCapacity'] as int? ?? 0;
                final status = d['status'] as String? ?? 'open';

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(activity,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('$date  •  $time',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black54)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('$filled/$max visitors',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.black54)),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: status == 'full'
                                  ? Colors.red.shade100
                                  : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status == 'full' ? 'Full' : 'Open',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: status == 'full'
                                    ? Colors.red.shade800
                                    : Colors.green.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
