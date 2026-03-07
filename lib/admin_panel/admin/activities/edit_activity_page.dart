import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/cloudinary_service.dart';

class EditActivityPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const EditActivityPage({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  State<EditActivityPage> createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  late TextEditingController nameController;
  late TextEditingController domesticController;
  late TextEditingController saarcController;
  late TextEditingController touristController;
  late List<TextEditingController> _slotControllers;

  File? _newImage;           // newly picked image (not yet uploaded)
  String? _existingImageUrl; // already stored network URL
  String? _existingAsset;    // legacy local asset path

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.data['title'] ?? '');
    domesticController = TextEditingController(
        text: (widget.data['domestic'] as num? ?? 0).toInt().toString());
    saarcController = TextEditingController(
        text: (widget.data['saarc'] as num? ?? 0).toInt().toString());
    touristController = TextEditingController(
        text: (widget.data['tourist'] as num? ?? 0).toInt().toString());

    final slots = List<String>.from(widget.data['timeSlots'] ?? ['']);
    _slotControllers =
        slots.map((s) => TextEditingController(text: s)).toList();
    if (_slotControllers.isEmpty) _slotControllers.add(TextEditingController());

    _existingImageUrl = widget.data['imageUrl'] as String?;
    _existingAsset = widget.data['image'] as String?;
  }

  @override
  void dispose() {
    nameController.dispose();
    domesticController.dispose();
    saarcController.dispose();
    touristController.dispose();
    for (final c in _slotControllers) c.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _newImage = File(picked.path);
        _existingImageUrl = null; // replace existing
        _existingAsset = null;
      });
    }
  }

  Future<String?> _uploadImage(String title) async {
    if (_newImage == null) return _existingImageUrl;
    return await CloudinaryService.uploadImage(_newImage!);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final slots = _slotControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one time slot')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final title = nameController.text.trim();
      final imageUrl = await _uploadImage(title);

      final updateData = <String, dynamic>{
        'title': title,
        'domestic': int.parse(domesticController.text.trim()),
        'saarc': int.parse(saarcController.text.trim()),
        'tourist': int.parse(touristController.text.trim()),
        'timeSlots': slots,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (imageUrl != null) {
        updateData['imageUrl'] = imageUrl;
        updateData.remove('image'); // remove legacy asset key if present
      }

      await FirebaseFirestore.instance
          .collection('activities')
          .doc(widget.docId)
          .update(updateData);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Activity'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image area
            GestureDetector(
              onTap: _saving ? null : _pickImage,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImagePreview(primary),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _saving ? null : _pickImage,
              icon: Icon(Icons.edit, size: 16, color: primary),
              label: Text('Change image', style: TextStyle(color: primary)),
            ),
            const SizedBox(height: 8),

            _field('Activity Name', nameController),
            const SizedBox(height: 14),
            _field('Domestic Price (Rs.)', domesticController, isNumber: true),
            const SizedBox(height: 14),
            _field('SAARC Price (Rs.)', saarcController, isNumber: true),
            const SizedBox(height: 14),
            _field('Other Tourists Price (Rs.)', touristController, isNumber: true),
            const SizedBox(height: 20),

            // Time slots
            Row(
              children: [
                const Text('Time Slots',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _slotControllers.add(TextEditingController())),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Slot'),
                ),
              ],
            ),
            ..._slotControllers.asMap().entries.map((entry) {
              final i = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: entry.value,
                        decoration: InputDecoration(
                          labelText: 'Slot ${i + 1} (e.g. 6–10 AM)',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 12),
                        ),
                      ),
                    ),
                    if (_slotControllers.length > 1) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.red),
                        onPressed: () =>
                            setState(() => _slotControllers.removeAt(i)),
                      ),
                    ],
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Changes', style: TextStyle(fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(Color primary) {
    if (_newImage != null) {
      return Image.file(_newImage!, fit: BoxFit.cover, width: double.infinity);
    }
    if (_existingImageUrl != null) {
      return CachedNetworkImage(
        imageUrl: _existingImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (_, __) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (_, __, ___) => _placeholder(primary),
      );
    }
    if (_existingAsset != null) {
      return Image.asset(_existingAsset!,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) => _placeholder(primary));
    }
    return _placeholder(primary);
  }

  Widget _placeholder(Color primary) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 40, color: primary),
        const SizedBox(height: 8),
        Text('Tap to add image', style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _field(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Required';
        if (isNumber && int.tryParse(v.trim()) == null) {
          return 'Enter a valid number';
        }
        return null;
      },
    );
  }
}
