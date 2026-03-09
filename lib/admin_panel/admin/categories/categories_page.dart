import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../shared/services/firebase_service.dart';
import '../../../data/cnp_species_data.dart';

class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  State<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  final FirebaseService _service = FirebaseService();
  static const _green = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    _service.seedCategories();
  }

  void _showCategoryDialog({DocumentSnapshot? doc}) {
    final nameController = TextEditingController(text: doc?['name'] ?? '');
    String selectedType = doc?['type'] ?? 'fauna';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(doc == null ? 'Add Category' : 'Edit Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setDialogState(() => selectedType = 'fauna'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedType == 'fauna' ? _green : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '🐾 Fauna',
                          style: TextStyle(
                            color: selectedType == 'fauna' ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setDialogState(() => selectedType = 'flora'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedType == 'flora' ? Colors.green.shade700 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '🌿 Flora',
                          style: TextStyle(
                            color: selectedType == 'flora' ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white),
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx);
                if (doc == null) {
                  // Get current count for order
                  final snap = await FirebaseFirestore.instance.collection('categories').get();
                  await _service.addCategory(name, selectedType, snap.docs.length + 1);
                } else {
                  await _service.updateCategory(doc.id, name, selectedType);
                }
              },
              child: Text(doc == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Delete "${doc['name']}"? This may affect species filtering.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await _service.deleteCategory(doc.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text('Edit Flora and Fauna'),
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.streamCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          final faunaDocs = docs.where((d) => d['type'] == 'fauna').toList();
          final floraDocs = docs.where((d) => d['type'] == 'flora').toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('🐾 Fauna', 'Animals & Wildlife', faunaDocs.length),
              ...faunaDocs.map((doc) => _buildCategoryTile(doc)),
              const SizedBox(height: 16),
              _buildSectionHeader('🌿 Flora', 'Plants & Vegetation', floraDocs.length),
              ...floraDocs.map((doc) => _buildCategoryTile(doc)),
              if (docs.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text('No categories yet. Tap + to add one.'),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(12)),
            child: Text('$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openSpeciesList(String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminSpeciesListPage(categoryName: categoryName),
      ),
    );
  }

  Widget _buildCategoryTile(DocumentSnapshot doc) {
    final isActive = doc['isActive'] as bool? ?? true;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => _openSpeciesList(doc['name'] as String),
        leading: CircleAvatar(
          backgroundColor: isActive ? const Color(0xFF2E7D32) : Colors.grey.shade300,
          child: Text(
            (doc['name'] as String).isNotEmpty ? (doc['name'] as String)[0] : '?',
            style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          doc['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black87 : Colors.grey,
            decoration: isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          doc['type'] == 'fauna' ? '🐾 Fauna' : '🌿 Flora',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: isActive,
              activeColor: const Color(0xFF2E7D32),
              onChanged: (val) => _service.toggleCategoryActive(doc.id, val),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF2E7D32)),
              onPressed: () => _showCategoryDialog(doc: doc),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(doc),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Species List Page with Edit/Delete ────────────────────────────────────────
class AdminSpeciesListPage extends StatefulWidget {
  final String categoryName;
  const AdminSpeciesListPage({super.key, required this.categoryName});

  @override
  State<AdminSpeciesListPage> createState() => _AdminSpeciesListPageState();
}

class _AdminSpeciesListPageState extends State<AdminSpeciesListPage> {
  final FirebaseService _service = FirebaseService();
  static const _green = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    _seedIfNeeded();
  }

  Future<void> _seedIfNeeded() async {
    final localList = allSpecies[widget.categoryName] ?? [];
    if (localList.isEmpty) return;
    await _service.seedSpeciesForCategory(
      widget.categoryName,
      localList.map((sp) => {
        'category': widget.categoryName,
        'englishName': sp.englishName,
        'nepaliName': sp.nepaliName,
        'scientificName': sp.scientificName,
        'habitat': sp.habitat,
        'conservationStatus': sp.conservationStatus,
        'description': sp.description,
        'funFact': sp.funFact,
      }).toList(),
    );
  }

  Color _statusColor(String status) {
    return statusColors[normalizeStatus(status)] ?? Colors.grey;
  }

  void _showEditDialog(DocumentSnapshot doc) {
    final englishCtrl = TextEditingController(text: doc['englishName']);
    final nepaliCtrl = TextEditingController(text: doc['nepaliName']);
    final sciCtrl = TextEditingController(text: doc['scientificName']);
    final habitatCtrl = TextEditingController(text: doc['habitat']);
    final descCtrl = TextEditingController(text: doc['description']);
    final funFactCtrl = TextEditingController(text: doc['funFact']);
    String status = doc['conservationStatus'];

    final statuses = [
      'Least Concern', 'Near Threatened', 'Vulnerable',
      'Endangered', 'Critically Endangered'
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDs) => AlertDialog(
          title: const Text('Edit Species'),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(englishCtrl, 'English Name'),
              _field(nepaliCtrl, 'Nepali Name'),
              _field(sciCtrl, 'Scientific Name'),
              _field(habitatCtrl, 'Habitat'),
              _field(descCtrl, 'Description', maxLines: 3),
              _field(funFactCtrl, 'Fun Fact', maxLines: 3),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(
                    labelText: 'Conservation Status',
                    border: OutlineInputBorder()),
                items: statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setDs(() => status = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _green, foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.pop(ctx);
                await _service.updateSpecies(doc.id, {
                  'englishName': englishCtrl.text.trim(),
                  'nepaliName': nepaliCtrl.text.trim(),
                  'scientificName': sciCtrl.text.trim(),
                  'habitat': habitatCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'funFact': funFactCtrl.text.trim(),
                  'conservationStatus': status,
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Species'),
        content: Text('Delete "${doc['englishName']}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await _service.deleteSpecies(doc.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  void _showAddDialog() {
    final englishCtrl = TextEditingController();
    final nepaliCtrl = TextEditingController();
    final sciCtrl = TextEditingController();
    final habitatCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final funFactCtrl = TextEditingController();
    String status = 'Least Concern';

    final statuses = [
      'Least Concern', 'Near Threatened', 'Vulnerable',
      'Endangered', 'Critically Endangered'
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDs) => AlertDialog(
          title: Text('Add ${widget.categoryName} Species'),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(englishCtrl, 'English Name'),
              _field(nepaliCtrl, 'Nepali Name'),
              _field(sciCtrl, 'Scientific Name'),
              _field(habitatCtrl, 'Habitat'),
              _field(descCtrl, 'Description', maxLines: 3),
              _field(funFactCtrl, 'Fun Fact', maxLines: 3),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(
                    labelText: 'Conservation Status',
                    border: OutlineInputBorder()),
                items: statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setDs(() => status = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _green, foregroundColor: Colors.white),
              onPressed: () async {
                final name = englishCtrl.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx);
                await _service.addSpecies({
                  'category': widget.categoryName,
                  'englishName': name,
                  'nepaliName': nepaliCtrl.text.trim(),
                  'scientificName': sciCtrl.text.trim(),
                  'habitat': habitatCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'funFact': funFactCtrl.text.trim(),
                  'conservationStatus': status,
                });
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        title: Text('${widget.categoryName} Species'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.streamSpeciesByCategory(widget.categoryName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = (snapshot.data?.docs ?? [])
            ..sort((a, b) => (a['englishName'] as String).compareTo(b['englishName'] as String));
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📭', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    'No species data for "${widget.categoryName}"',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              Container(
                width: double.infinity,
                color: _green.withOpacity(0.1),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Text(
                  '${docs.length} species found',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: _green),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final statusColor =
                        _statusColor(doc['conservationStatus'] ?? '');
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: statusColor.withOpacity(0.15),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(doc['englishName'] ?? '',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc['nepaliName'] ?? '',
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(
                                doc['conservationStatus'] ?? '',
                                style: TextStyle(
                                    color: statusColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: _green, size: 20),
                              onPressed: () => _showEditDialog(doc),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 20),
                              onPressed: () => _confirmDelete(doc),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),
                                _infoRow(Icons.science, 'Scientific Name',
                                    doc['scientificName'] ?? ''),
                                _infoRow(Icons.forest, 'Habitat',
                                    doc['habitat'] ?? ''),
                                _infoRow(Icons.info_outline, 'Description',
                                    doc['description'] ?? ''),
                                _infoRow(Icons.lightbulb_outline, 'Fun Fact',
                                    doc['funFact'] ?? ''),
                              ],
                            ),
                          ),
                        ],
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _green),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 13),
                children: [
                  TextSpan(
                      text: '$label: ',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
