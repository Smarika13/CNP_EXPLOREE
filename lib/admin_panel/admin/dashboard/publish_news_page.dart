import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/cloudinary_service.dart';

class PublishNewsPage extends StatelessWidget {
  const PublishNewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1B5E20);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Post'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const _ComposePostPage()),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('No posts yet. Tap + to create one.',
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;
              return _AdminPostCard(docId: doc.id, data: data);
            },
          );
        },
      ),
    );
  }
}

// ── Admin Post Card ────────────────────────────────────────────────────────────
class _AdminPostCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  const _AdminPostCard({required this.docId, required this.data});

  void _showEngagementSheet(BuildContext context, String postId,
      List<QueryDocumentSnapshot> reactionDocs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AdminEngagementSheet(
          postId: postId, reactionDocs: reactionDocs),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Post'),
        content: const Text('Remove this post from the news feed?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('news')
                  .doc(docId)
                  .delete();
              if (context.mounted) Navigator.pop(context);
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1B5E20);
    final String title = data['title'] ?? '';
    final String body = data['body'] ?? data['subtitle'] ?? '';
    final String? imageUrl = data['imageUrl'] as String?;
    final Timestamp? ts = data['timestamp'] as Timestamp?;
    final String timeStr = ts != null
        ? DateFormat('MMM d, yyyy • h:mm a').format(ts.toDate())
        : '';
    final int commentsCount =
        (data['commentsCount'] as num? ?? 0).toInt();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: primary.withOpacity(0.15),
                  child: Icon(Icons.park, size: 18, color: primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CNP Admin',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      if (timeStr.isNotEmpty)
                        Text(timeStr,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black45)),
                    ],
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context),
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
              height: 200,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 200,
                color: Colors.grey.shade100,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 200,
                color: Colors.grey.shade100,
                child: const Icon(Icons.broken_image_outlined,
                    color: Colors.grey),
              ),
            ),
          ],

          // Text content
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

          // Reaction + comment summary with tap to view details
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('news')
                .doc(docId)
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                    child: Row(
                      children: [
                        if (counts.isNotEmpty)
                          Text(
                            counts.entries
                                .map((e) => '${e.key} ${e.value}')
                                .join('  '),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          )
                        else
                          const Text('No reactions yet',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black38)),
                        const Spacer(),
                        Text(
                            '$commentsCount comment${commentsCount == 1 ? '' : 's'}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black38)),
                      ],
                    ),
                  ),
                  // View details button
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                    ),
                    onPressed: () => _showEngagementSheet(
                        context, docId, reactionDocs),
                    icon: const Icon(Icons.bar_chart, size: 15),
                    label: const Text('View reactions & comments',
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Admin Engagement Sheet ─────────────────────────────────────────────────────
class _AdminEngagementSheet extends StatefulWidget {
  final String postId;
  final List<QueryDocumentSnapshot> reactionDocs;

  const _AdminEngagementSheet({
    required this.postId,
    required this.reactionDocs,
  });

  @override
  State<_AdminEngagementSheet> createState() => _AdminEngagementSheetState();
}

class _AdminEngagementSheetState extends State<_AdminEngagementSheet> {
  // uid → resolved display name
  Map<String, String> _resolvedNames = {};
  bool _loadingNames = true;

  @override
  void initState() {
    super.initState();
    _resolveNames();
  }

  Future<void> _resolveNames() async {
    final Map<String, String> resolved = {};

    // Collect UIDs that need resolution
    final List<String> uidsToFetch = [];
    for (final d in widget.reactionDocs) {
      final data = d.data() as Map<String, dynamic>;
      final stored = data['userName'] as String?;
      // Accept stored name only if it's a real name (not placeholder)
      if (stored != null && stored.isNotEmpty && stored != 'User') {
        resolved[d.id] = stored;
      } else {
        uidsToFetch.add(d.id);
      }
    }

    // Batch-fetch missing names from users collection
    for (final uid in uidsToFetch) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        final name = doc.data()?['fullName'] as String? ?? '';
        resolved[uid] = name.isNotEmpty ? name : 'Unknown User';
      } catch (_) {
        resolved[uid] = 'Unknown User';
      }
    }

    if (mounted) {
      setState(() {
        _resolvedNames = resolved;
        _loadingNames = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group reactions by emoji → list of names
    final Map<String, List<String>> byEmoji = {};
    for (final d in widget.reactionDocs) {
      final data = d.data() as Map<String, dynamic>;
      final emoji = data['emoji'] as String? ?? '';
      final name = _resolvedNames[d.id] ?? '...';
      if (emoji.isNotEmpty) {
        byEmoji.putIfAbsent(emoji, () => []).add(name);
      }
    }

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
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Engagement',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                TabBar(
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.black45,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  tabs: [
                    Tab(text: 'Reactions (${widget.reactionDocs.length})'),
                    const Tab(text: 'Comments'),
                  ],
                ),
                const Divider(height: 1),
                Expanded(
                  child: TabBarView(
                    children: [
                      // ── Reactions Tab ──
                      _loadingNames
                          ? const Center(child: CircularProgressIndicator())
                          : byEmoji.isEmpty
                          ? const Center(
                              child: Text('No reactions yet.',
                                  style:
                                      TextStyle(color: Colors.grey)))
                          : ListView(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              children: byEmoji.entries.map((entry) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 6, top: 4),
                                      child: Text(
                                        '${entry.key}  ${entry.value.length}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    ...entry.value.map((name) => Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundColor: Theme.of(
                                                        context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.1),
                                                child: Text(
                                                  name.isNotEmpty
                                                      ? name[0]
                                                          .toUpperCase()
                                                      : '?',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(
                                                              context)
                                                          .colorScheme
                                                          .primary,
                                                      fontWeight:
                                                          FontWeight
                                                              .bold),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(name,
                                                  style: const TextStyle(
                                                      fontSize: 13)),
                                            ],
                                          ),
                                        )),
                                    const Divider(),
                                  ],
                                );
                              }).toList(),
                            ),

                      // ── Comments Tab ──
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('news')
                            .doc(widget.postId)
                            .collection('comments')
                            .orderBy('timestamp', descending: false)
                            .snapshots(),
                        builder: (context, snap) {
                          if (snap.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final comments = snap.data?.docs ?? [];
                          if (comments.isEmpty) {
                            return const Center(
                                child: Text('No comments yet.',
                                    style:
                                        TextStyle(color: Colors.grey)));
                          }
                          return ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: comments.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final d = comments[i].data()
                                  as Map<String, dynamic>;
                              final commentId = comments[i].id;
                              final String name =
                                  d['userName'] ?? 'Unknown User';
                              final String text = d['text'] ?? '';
                              final Timestamp? ts =
                                  d['timestamp'] as Timestamp?;
                              final String time = ts != null
                                  ? DateFormat('MMM d • h:mm a')
                                      .format(ts.toDate())
                                  : '';
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1),
                                      child: Text(
                                        name.isNotEmpty
                                            ? name[0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13)),
                                              if (time.isNotEmpty) ...[
                                                const SizedBox(width: 6),
                                                Text(time,
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors
                                                            .black38)),
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
                                    // Admin delete comment
                                    IconButton(
                                      icon: const Icon(
                                          Icons.delete_outline,
                                          size: 16,
                                          color: Colors.red),
                                      onPressed: () async {
                                        final batch = FirebaseFirestore
                                            .instance
                                            .batch();
                                        batch.delete(FirebaseFirestore
                                            .instance
                                            .collection('news')
                                            .doc(widget.postId)
                                            .collection('comments')
                                            .doc(commentId));
                                        batch.update(
                                            FirebaseFirestore.instance
                                                .collection('news')
                                                .doc(widget.postId),
                                            {
                                              'commentsCount':
                                                  FieldValue.increment(-1)
                                            });
                                        await batch.commit();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Compose Post Page ──────────────────────────────────────────────────────────
class _ComposePostPage extends StatefulWidget {
  const _ComposePostPage();

  @override
  State<_ComposePostPage> createState() => _ComposePostPageState();
}

class _ComposePostPageState extends State<_ComposePostPage> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  File? _image;
  bool _posting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _post() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty && body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something before posting')),
      );
      return;
    }
    setState(() => _posting = true);
    try {
      String? imageUrl;
      if (_image != null) {
        imageUrl =
            await CloudinaryService.uploadImage(_image!, folder: 'news');
      }
      await FirebaseFirestore.instance.collection('news').add({
        'title': title,
        'body': body,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'commentsCount': 0,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _posting = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1B5E20);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text('New Post'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _posting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : TextButton(
                    onPressed: _post,
                    child: const Text('Post',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Image picker
          GestureDetector(
            onTap: _posting ? null : _pickImage,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_image!,
                          fit: BoxFit.cover, width: double.infinity),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_outlined,
                            size: 40, color: primary),
                        const SizedBox(height: 8),
                        Text('Tap to add a photo (optional)',
                            style:
                                TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
            ),
          ),
          if (_image != null)
            TextButton.icon(
              onPressed: () => setState(() => _image = null),
              icon: const Icon(Icons.close, size: 16, color: Colors.red),
              label: const Text('Remove photo',
                  style: TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 16),

          // Title
          TextField(
            controller: _titleCtrl,
            enabled: !_posting,
            decoration: InputDecoration(
              hintText: 'Title (optional)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            ),
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          // Body
          TextField(
            controller: _bodyCtrl,
            enabled: !_posting,
            maxLines: 7,
            decoration: InputDecoration(
              hintText: "What's happening at CNP? Write your update...",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
