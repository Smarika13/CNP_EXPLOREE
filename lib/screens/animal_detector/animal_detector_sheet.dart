import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

const Color _green = Color(0xFF1B5E20);
const Color _greenLight = Color(0xFF4CAF50);

/// Data for each detectable animal — shown after a successful scan.
const Map<String, Map<String, dynamic>> _animalData = {
  'Tiger': {
    'emoji': '🐯',
    'scientificName': 'Panthera tigris tigris',
    'conservationStatus': 'Endangered',
    'statusColor': Colors.red,
    'habitat': 'Dense forests, grasslands, and wetlands of Chitwan.',
    'diet': 'Carnivore — mainly deer, wild boar, and buffalo.',
    'whereToSpot':
        'Best spotted in the core zones near Sauraha, Kasara, and along the Rapti River buffer zone. Early morning jeep safaris in the Icharni and Baghmara areas offer the highest sighting rates.',
    'facts': [
      'There are over 120 tigers in Chitwan, making it a global hotspot for tiger conservation.',
      'Only Bengal tigers are found in Nepal, and they are the largest tiger subspecies.',
      'Nepal has over 350 wild tigers, up from 121 in 2009.',
      'A tiger\'s roar can be heard up to 3 km away.',
      'No two tigers have the same stripe pattern.',
      'They are excellent swimmers and love water.',
    ],
  },
  'Elephant': {
    'emoji': '🐘',
    'scientificName': 'Elephas maximus',
    'conservationStatus': 'Endangered',
    'statusColor': Colors.red,
    'habitat': 'Tropical forests and grasslands along river valleys.',
    'diet': 'Herbivore — grasses, bark, fruits, and roots.',
    'whereToSpot':
        'Commonly seen in the tall elephant grass of the Beeshazar Lakes area and the Devi\'s Forest zone. The Bagmara Community Forest is another reliable sighting location.',
    'facts': [
      'There are around 600 wild elephants in Nepal, with a significant population in Chitwan.',
      'An elephant eats up to 150 kg of food per day.',
      'They can recognize themselves in a mirror.',
      'Their trunk has over 40,000 muscles.',
      'Chitwan uses trained elephants for anti-poaching patrols.',
    ],
  },
  'Rhino': {
    'emoji': '🦏',
    'scientificName': 'Rhinoceros unicornis',
    'conservationStatus': 'Vulnerable',
    'statusColor': Colors.orange,
    'habitat': 'Tall grasslands and riverine forests of the Terai.',
    'diet': 'Herbivore — grasses, leaves, fruits, and aquatic plants.',
    'whereToSpot':
        'Frequently seen in the Icharni grasslands, near the Rapti and Narayani rivers, and the Lamichaur area. They are often spotted wallowing in muddy water holes during afternoon hours.',
    'facts': [
      'Nepal\'s one-horned rhino population has grown to over 750.',
      'Their horn is made of keratin, the same as human nails.',
      'Rhinos can run up to 55 km/h despite their size.',
      'Chitwan is a global success story for rhino conservation.',
    ],
  },
  'Mugger Crocodile': {
    'emoji': '🐊',
    'scientificName': 'Crocodylus palustris',
    'conservationStatus': 'Vulnerable',
    'statusColor': Colors.orange,
    'habitat': 'Freshwater rivers, lakes, and marshes of Chitwan.',
    'diet': 'Carnivore — fish, frogs, birds, and small mammals.',
    'whereToSpot':
        'Regularly seen basking on the sandy banks of the Rapti River near Sauraha. Canoe safaris along the Rapti at dawn or dusk offer close-up sightings.',
    'facts': [
      'Mugger crocodiles can live up to 100 years.',
      'They are one of the most social crocodile species.',
      'Females lay 25–30 eggs and guard the nest fiercely.',
      'The Rapti River in Chitwan is a key mugger habitat.',
    ],
  },
  'Gharial': {
    'emoji': '🐊',
    'scientificName': 'Gavialis gangeticus',
    'conservationStatus': 'Critically Endangered',
    'statusColor': Colors.red,
    'habitat': 'Deep, fast-flowing rivers like the Narayani in Chitwan.',
    'diet': 'Carnivore — almost exclusively fish.',
    'whereToSpot':
        'The Narayani River near Kasara is the best location. The Gharial Conservation and Breeding Centre at Kasara can also be visited.',
    'facts': [
      'Gharials are one of the most critically endangered reptiles.',
      'Their long narrow snout is perfectly adapted for catching fish.',
      'Males develop a bulbous growth (ghara) on their snout.',
      'They can grow up to 6 metres long.',
      'Chitwan\'s Narayani River is one of their last safe havens.',
    ],
  },
};

// Raw label → display name overrides
const Map<String, String> _labelToDisplayName = {
  'TheMuggerCrocodile': 'Mugger Crocodile',
};

class AnimalDetectorSheet extends StatefulWidget {
  const AnimalDetectorSheet({super.key});

  @override
  State<AnimalDetectorSheet> createState() => _AnimalDetectorSheetState();
}

class _AnimalDetectorSheetState extends State<AnimalDetectorSheet> {
  File? _image;
  bool _isScanning = false;
  String? _detectedAnimal;
  double _confidence = 0.0;
  Interpreter? _interpreter;
  List<String>? _labels;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/animal_model.tflite');
      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData.split('\n').where((s) => s.isNotEmpty).toList();
    } catch (e) {
      debugPrint('Error loading model: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _isScanning = true;
        _detectedAnimal = null;
      });
      await _runInference(_image!);
    }
  }

  void _resetScan() {
    setState(() {
      _image = null;
      _detectedAnimal = null;
      _confidence = 0.0;
      _isScanning = false;
    });
  }

  List<double> _inferenceOnImage(img.Image image) {
    final resized = img.copyResize(image, width: 224, height: 224);
    var input = Float32List(1 * 224 * 224 * 3);
    int idx = 0;
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        input[idx++] = pixel.r / 255.0;
        input[idx++] = pixel.g / 255.0;
        input[idx++] = pixel.b / 255.0;
      }
    }
    var output = List<double>.filled(_labels!.length, 0)
        .reshape([1, _labels!.length]);
    _interpreter!.run(input.reshape([1, 224, 224, 3]), output);
    return List<double>.from(output[0]);
  }

  Future<void> _runInference(File imageFile) async {
    if (_interpreter == null || _labels == null) return;

    final imageData = await imageFile.readAsBytes();
    img.Image? originalImage = img.decodeImage(imageData);
    if (originalImage == null) {
      setState(() => _isScanning = false);
      return;
    }
    // Apply EXIF orientation so rotated/flipped photos are corrected before inference
    originalImage = img.bakeOrientation(originalImage);

    // Run inference on original + slight crop variation, average results
    final variants = [
      originalImage,
      img.copyRotate(originalImage, angle: 5),
      img.copyRotate(originalImage, angle: -5),
    ];

    final avgProbs = List<double>.filled(_labels!.length, 0.0);
    for (final variant in variants) {
      final probs = _inferenceOnImage(variant);
      for (int i = 0; i < probs.length; i++) {
        avgProbs[i] += probs[i] / variants.length;
      }
    }

    final sorted = List<double>.from(avgProbs)..sort((a, b) => b.compareTo(a));
    final bestConf = sorted[0];
    final margin = sorted[0] - sorted[1];
    final bestIndex = avgProbs.indexOf(bestConf);

    // Require: confidence >= 0.50 AND margin >= 0.10 over 2nd place
    const double confidenceThreshold = 0.50;
    const double marginThreshold = 0.10;

    setState(() {
      _isScanning = false;
      _confidence = bestConf;
      if (bestConf < confidenceThreshold || margin < marginThreshold) {
        _detectedAnimal = null;
      } else {
        final raw = _labels![bestIndex];
        _detectedAnimal = _labelToDisplayName[raw] ?? raw;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.center_focus_weak, color: _green),
                  const SizedBox(width: 10),
                  const Text(
                    'Visual Identifier',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (_image != null && !_isScanning)
                    IconButton(
                      icon: const Icon(Icons.refresh, color: _green),
                      tooltip: 'Scan another',
                      onPressed: _resetScan,
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Image preview
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _image != null
                          ? Image.file(_image!,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover)
                          : Container(
                              height: 220,
                              width: double.infinity,
                              color: Colors.grey.shade100,
                              child: const Icon(Icons.image,
                                  size: 80, color: Colors.grey),
                            ),
                    ),
                    const SizedBox(height: 20),
                    // Camera / Gallery buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Camera'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Result area
                    if (_isScanning)
                      const Column(
                        children: [
                          CircularProgressIndicator(color: _green),
                          SizedBox(height: 12),
                          Text('Identifying animal...',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    else if (_image == null)
                      Text(
                        'Take or upload a photo to identify a Chitwan animal',
                        style: TextStyle(
                            fontSize: 15, color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      )
                    else if (_detectedAnimal == null)
                      _NotFoundCard(onRetry: _resetScan,
                          onOk: () => Navigator.pop(context))
                    else
                      _AnimalInfoCard(
                        animalName: _detectedAnimal!,
                        confidence: _confidence,
                        data: _animalData[_detectedAnimal!] ??
                            _animalData['Tiger']!,
                        onRetry: _resetScan,
                        onOk: () => Navigator.pop(context),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Not-found card ───────────────────────────────────────────────────────────

class _NotFoundCard extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onOk;
  const _NotFoundCard({required this.onRetry, required this.onOk});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 10),
          const Text(
            'Not Recognized',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'This image does not match any animal in our database. '
            'Please try a clearer photo of a Chitwan wildlife animal.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, height: 1.6),
          ),
          const SizedBox(height: 8),
          Text(
            'Currently supported: Tiger, Elephant, Rhino, Mugger Crocodile & Gharial.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onOk,
                  icon: const Icon(Icons.check),
                  label: const Text('OK'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Animal info card ─────────────────────────────────────────────────────────

class _AnimalInfoCard extends StatelessWidget {
  final String animalName;
  final double confidence;
  final Map<String, dynamic> data;
  final VoidCallback onRetry;
  final VoidCallback onOk;

  const _AnimalInfoCard({
    required this.animalName,
    required this.confidence,
    required this.data,
    required this.onRetry,
    required this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = data['statusColor'] as Color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _green.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _green.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Text(data['emoji'], style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 8),
              Text(animalName,
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: _green)),
              Text(data['scientificName'],
                  style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _Badge(data['conservationStatus'], statusColor),
                  _Badge('${(confidence * 100).toStringAsFixed(1)}% match',
                      _greenLight),
                  _Badge('🇳🇵 Found in Nepal', Colors.blue),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InfoSection(
          icon: Icons.restaurant,
          title: 'Diet & Habitat',
          content: '🍖 ${data['diet']}\n\n🌿 ${data['habitat']}',
        ),
        const SizedBox(height: 12),
        _InfoSection(
          icon: Icons.location_on,
          title: 'Where to Spot in CNP',
          content: data['whereToSpot'],
          iconColor: Colors.teal,
          bgColor: Colors.teal.shade50,
          borderColor: Colors.teal.shade100,
        ),
        const SizedBox(height: 12),
        _InfoSection(
          icon: Icons.science,
          title: 'Scientific Name',
          content: data['scientificName'],
          isItalic: true,
        ),
        const SizedBox(height: 12),
        // Fun facts
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text('Fun Facts',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ]),
              const SizedBox(height: 10),
              ...(data['facts'] as List<String>).map((fact) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ',
                            style: TextStyle(
                                color: Colors.amber, fontSize: 18)),
                        Expanded(
                            child: Text(fact,
                                style: const TextStyle(fontSize: 13))),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Scan Again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _green,
                  side: const BorderSide(color: _green),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onOk,
                icon: const Icon(Icons.check),
                label: const Text('Done'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final bool isItalic;
  final Color iconColor;
  final Color? bgColor;
  final Color? borderColor;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.content,
    this.isItalic = false,
    this.iconColor = _green,
    this.bgColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ]),
          const SizedBox(height: 8),
          Text(content,
              style: TextStyle(
                  fontSize: 13,
                  fontStyle:
                      isItalic ? FontStyle.italic : FontStyle.normal,
                  color: Colors.grey.shade700,
                  height: 1.6)),
        ],
      ),
    );
  }
}
