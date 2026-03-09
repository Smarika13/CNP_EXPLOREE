import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _kEmojis = ['❤️', '👍', '😮', '😢'];

class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists && mounted) {
      setState(() {
        _userName =
            (doc.data()?['fullName'] as String? ?? '').isNotEmpty
                ? doc.data()!['fullName'] as String
                : 'User';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B5E20);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F5),
        body: Column(
          children: [
            const SizedBox(height: 16),

            // TabBar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const TabBar(
                labelColor: primaryGreen,
                unselectedLabelColor: Colors.black54,
                indicatorColor: primaryGreen,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(icon: Icon(Icons.notifications), text: "Notifications"),
                  Tab(icon: Icon(Icons.newspaper), text: "News"),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: TabBarView(
                children: [
                  // ── Notifications Tab ────────────────────────────────
                  _BookingNotifications(),

                  // ── News Tab ─────────────────────────────────────────
                  _NewsFeed(currentUserName: _userName),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Booking Notifications ──────────────────────────────────────────────────────
class _BookingNotifications extends StatelessWidget {
  _BookingNotifications();

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B5E20);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text('Please log in to see notifications.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: uid)
          .orderBy('bookingTimestamp', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_none_outlined,
                    size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text('No notifications yet.',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final activity = data['activity'] as String? ?? 'Activity';
            final date = data['date'] as String? ?? '';
            final time = data['time'] as String? ?? '';
            final status = data['status'] as String? ?? 'Confirmed';
            final Timestamp? ts = data['bookingTimestamp'] as Timestamp?;
            final timeStr = ts != null
                ? DateFormat('MMM d, yyyy • h:mm a').format(ts.toDate())
                : '';

            final isConfirmed = status == 'Confirmed';
            final isPaid = data['paymentStatus'] == 'Paid';

            // Support multiple guides (new) with fallback to single-guide fields (legacy)
            final rawGuides = data['assignedGuides'] as List<dynamic>?;
            final List<Map<String, String>> assignedGuides = rawGuides != null
                ? rawGuides.map((g) {
                    final m = g as Map<String, dynamic>;
                    return {
                      'name':  m['name']  as String? ?? '',
                      'phone': m['phone'] as String? ?? '',
                      'email': m['email'] as String? ?? '',
                    };
                  }).where((g) => g['name']!.isNotEmpty).toList()
                : () {
                    final n = data['guideName'] as String? ?? '';
                    if (n.isEmpty) return <Map<String, String>>[];
                    return [{'name': n, 'phone': data['guidePhone'] as String? ?? '', 'email': data['guideEmail'] as String? ?? ''}];
                  }();
            final hasGuide = assignedGuides.isNotEmpty;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isConfirmed
                              ? const Color(0xFFE8F5E9)
                              : Colors.orange.shade50,
                          child: Icon(
                            isConfirmed
                                ? Icons.check_circle_outline
                                : Icons.pending_outlined,
                            color: isConfirmed ? primaryGreen : Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isConfirmed
                                    ? 'Booking Confirmed — $activity'
                                    : 'Booking Pending — $activity',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text('$date  •  $time',
                                  style: const TextStyle(fontSize: 12)),
                              if (timeStr.isNotEmpty)
                                Text('Booked on $timeStr',
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.black45)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isPaid && hasGuide) ...[
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      for (int gi = 0; gi < assignedGuides.length; gi++) ...[
                        if (gi > 0) const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.person_pin, size: 15, color: Color(0xFF1B5E20)),
                            const SizedBox(width: 6),
                            Text(
                              assignedGuides.length > 1
                                  ? 'Guide ${gi + 1}: ${assignedGuides[gi]['name']}'
                                  : 'Guide: ${assignedGuides[gi]['name']}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        if ((assignedGuides[gi]['phone'] ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 14, color: Colors.black45),
                              const SizedBox(width: 6),
                              Text(assignedGuides[gi]['phone']!,
                                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ],
                        if ((assignedGuides[gi]['email'] ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.email_outlined, size: 14, color: Colors.black45),
                              const SizedBox(width: 6),
                              Text(assignedGuides[gi]['email']!,
                                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── News Feed ──────────────────────────────────────────────────────────────────
class _NewsFeed extends StatelessWidget {
  final String currentUserName;
  const _NewsFeed({required this.currentUserName});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('news')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.newspaper_outlined,
                    size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text('No news updates at the moment.',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            return _PostCard(
              postId: doc.id,
              data: data,
              currentUserName: currentUserName,
            );
          },
        );
      },
    );
  }
}

// ── Post Card ──────────────────────────────────────────────────────────────────
class _PostCard extends StatelessWidget {
  final String postId;
  final Map<String, dynamic> data;
  final String currentUserName;

  const _PostCard({
    required this.postId,
    required this.data,
    required this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    final String title = data['title'] ?? '';
    final String body = data['body'] ?? data['subtitle'] ?? '';
    final String? imageUrl = data['imageUrl'] as String?;
    final Timestamp? ts = data['timestamp'] as Timestamp?;
    final String timeStr = ts != null
        ? DateFormat('MMM d, yyyy • h:mm a').format(ts.toDate())
        : '';
    final int commentsCount =
        (data['commentsCount'] as num? ?? 0).toInt();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.park, size: 18, color: Color(0xFF1B5E20)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CNP Official',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      if (timeStr.isNotEmpty)
                        Text(timeStr,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black45)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Image
          if (imageUrl != null && imageUrl.isNotEmpty) ...[
            const SizedBox(height: 10),
            CachedNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 220,
                color: Colors.grey.shade100,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 220,
                color: Colors.grey.shade100,
                child: const Icon(Icons.broken_image_outlined,
                    color: Colors.grey),
              ),
            ),
          ],

          // Text content
          if (title.isNotEmpty || body.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  if (title.isNotEmpty && body.isNotEmpty)
                    const SizedBox(height: 4),
                  if (body.isNotEmpty)
                    Text(body,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87)),
                ],
              ),
            ),

          const Divider(height: 1),

          // Reaction summary row
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('news')
                .doc(postId)
                .collection('reactions')
                .snapshots(),
            builder: (context, reactSnap) {
              final reactionDocs = reactSnap.data?.docs ?? [];
              final Map<String, int> counts = {};
              for (final d in reactionDocs) {
                final emoji =
                    (d.data() as Map)['emoji'] as String? ?? '';
                if (emoji.isNotEmpty) {
                  counts[emoji] = (counts[emoji] ?? 0) + 1;
                }
              }

              // Current user's reaction
              String? myReaction;
              if (uid.isNotEmpty) {
                final matching =
                    reactionDocs.where((d) => d.id == uid).toList();
                if (matching.isNotEmpty) {
                  myReaction =
                      (matching.first.data() as Map)['emoji'] as String?;
                }
              }

              return Column(
                children: [
                  // Reaction count summary
                  if (reactionDocs.isNotEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(14, 8, 14, 0),
                      child: Row(
                        children: [
                          Text(
                            counts.entries
                                .map((e) => '${e.key} ${e.value}')
                                .join('  '),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),

                  // Reaction buttons + Comments button
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      children: [
                        // Emoji reaction buttons
                        ..._kEmojis.map((emoji) {
                          final isSelected = myReaction == emoji;
                          return _ReactionButton(
                            emoji: emoji,
                            isSelected: isSelected,
                            onTap: () =>
                                _toggleReaction(uid, emoji, myReaction),
                          );
                        }),

                        const Spacer(),

                        // Comments button
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black54,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                          onPressed: () => _openComments(
                              context, postId, commentsCount, currentUserName),
                          icon: const Icon(Icons.chat_bubble_outline, size: 16),
                          label: Text('$commentsCount',
                              style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _toggleReaction(
      String uid, String emoji, String? currentReaction) async {
    if (uid.isEmpty) return;
    final ref = FirebaseFirestore.instance
        .collection('news')
        .doc(postId)
        .collection('reactions')
        .doc(uid);

    if (currentReaction == emoji) {
      await ref.delete();
    } else {
      final name = await _resolveUserName(uid, currentUserName);
      await ref.set({'emoji': emoji, 'userName': name});
    }
  }

  /// Returns a reliable display name — uses pre-loaded name if valid,
  /// otherwise fetches fresh from Firestore.
  static Future<String> _resolveUserName(String uid, String cached) async {
    if (cached.isNotEmpty && cached != 'User') return cached;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final name = doc.data()?['fullName'] as String? ?? '';
      return name.isNotEmpty ? name : 'User';
    } catch (_) {
      return cached.isNotEmpty ? cached : 'User';
    }
  }

  void _openComments(BuildContext context, String postId, int count,
      String currentUserName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(
        postId: postId,
        currentUserName: currentUserName,
      ),
    );
  }
}

// ── Reaction Button ────────────────────────────────────────────────────────────
class _ReactionButton extends StatelessWidget {
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1B5E20).withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: const Color(0xFF1B5E20).withOpacity(0.4))
              : null,
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

// ── Comments Bottom Sheet ──────────────────────────────────────────────────────
class _CommentsSheet extends StatefulWidget {
  final String postId;
  final String currentUserName;

  const _CommentsSheet({
    required this.postId,
    required this.currentUserName,
  });

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _commentCtrl = TextEditingController();
  bool _posting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    setState(() => _posting = true);

    try {
      // Always resolve name fresh to avoid placeholder names
      final name =
          await _PostCard._resolveUserName(uid, widget.currentUserName);

      final batch = FirebaseFirestore.instance.batch();

      // Add comment
      final commentRef = FirebaseFirestore.instance
          .collection('news')
          .doc(widget.postId)
          .collection('comments')
          .doc();
      batch.set(commentRef, {
        'userId': uid,
        'userName': name,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Increment commentsCount on the post
      final postRef = FirebaseFirestore.instance
          .collection('news')
          .doc(widget.postId);
      batch.update(postRef, {
        'commentsCount': FieldValue.increment(1),
      });

      await batch.commit();
      _commentCtrl.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final batch = FirebaseFirestore.instance.batch();
    batch.delete(FirebaseFirestore.instance
        .collection('news')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId));
    batch.update(
        FirebaseFirestore.instance.collection('news').doc(widget.postId),
        {'commentsCount': FieldValue.increment(-1)});
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              const Text('Comments',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const Divider(),

              // Comments list
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('news')
                      .doc(widget.postId)
                      .collection('comments')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    final comments = snap.data?.docs ?? [];
                    if (comments.isEmpty) {
                      return Center(
                        child: Text('No comments yet. Be the first!',
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13)),
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: comments.length,
                      itemBuilder: (context, i) {
                        final d =
                            comments[i].data() as Map<String, dynamic>;
                        final commentId = comments[i].id;
                        final String name = d['userName'] ?? 'User';
                        final String text = d['text'] ?? '';
                        final Timestamp? ts =
                            d['timestamp'] as Timestamp?;
                        final String time = ts != null
                            ? DateFormat('MMM d • h:mm a')
                                .format(ts.toDate())
                            : '';
                        final bool isOwn = d['userId'] == uid;

                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    const Color(0xFF1B5E20).withOpacity(0.1),
                                child: Text(
                                  name.isNotEmpty
                                      ? name[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF1B5E20),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13)),
                                        if (time.isNotEmpty) ...[
                                          const SizedBox(width: 6),
                                          Text(time,
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.black38)),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(text,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87)),
                                  ],
                                ),
                              ),
                              if (isOwn)
                                GestureDetector(
                                  onTap: () =>
                                      _deleteComment(commentId),
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Icon(Icons.close,
                                        size: 16, color: Colors.black26),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Input
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      12,
                      8,
                      12,
                      MediaQuery.of(context).viewInsets.bottom + 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          enabled: !_posting,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _posting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2))
                          : IconButton(
                              onPressed: _submitComment,
                              icon: const Icon(Icons.send_rounded,
                                  color: Color(0xFF1B5E20)),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
