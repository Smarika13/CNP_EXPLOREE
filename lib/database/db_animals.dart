import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// -------------------------------------------------------------------
// 1. THE DATA MODEL
// -------------------------------------------------------------------
class Animal {
  final String id;
  final String name;
  final String status;
  final String mainImg;      // Synchronized naming
  final List<String> moreImg; // Synchronized naming
  final String description;
  final String category;
  final String diet;

  Animal({
    required this.id,
    required this.name,
    required this.status,
    required this.mainImg,
    required this.moreImg,
    required this.description,
    required this.category,
    required this.diet,
  });

  factory Animal.fromFirestore(Map<String, dynamic> data, String docId) {
    return Animal(
      id: docId,
      name: data['name'] ?? 'Unknown Species',
      status: data['status'] ?? 'Vulnerable',
      // Using 'mainImg' to match the Node.js seeder and common JS standards
      mainImg: data['mainImg'] ?? '', 
      moreImg: List<String>.from(data['moreImg'] ?? []),
      description: data['descriptions'] ?? 'No description available.',
      category: data['category'] ?? 'Mammal',
      diet: data['diet'] ?? 'Unknown',
    );
  }
}

// -------------------------------------------------------------------
// 2. THE QUERY & UPLOAD SERVICE
// -------------------------------------------------------------------
class AnimalQueryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- PRIVATE HELPER: UPLOAD TO STORAGE ---
  Future<String> _uploadFile(File file, String path) async {
    Reference ref = _storage.ref().child(path);
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // --- FEATURE: UPLOAD FULL ANIMAL DATA ---
  Future<void> uploadFullAnimalData({
    required String name,
    required String status,
    required String description,
    required String category,
    required String diet,
    required File mainImageFile,
    required List<File> moreImageFiles,
  }) async {
    try {
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String folderName = name.toLowerCase().replaceAll(' ', '_');

      // 1. Parallel uploads
      Future<String> mainImgTask = _uploadFile(
        mainImageFile, 
        'animals/$folderName/${folderName}_main_$timestamp.jpg'
      );

      List<Future<String>> galleryTasks = moreImageFiles.asMap().entries.map((entry) {
        return _uploadFile(
          entry.value, 
          'animals/$folderName/${folderName}_gallery_${entry.key}_$timestamp.jpg'
        );
      }).toList();

      String mainImgUrl = await mainImgTask;
      List<String> moreImgUrls = await Future.wait(galleryTasks);

      // 3. Save to Firestore (Synchronized keys)
      await _db.collection('animals').add({
        'name': name,
        'status': status,
        'descriptions': description,
        'category': category,
        'diet': diet,
        'mainImg': mainImgUrl, // camelCase
        'moreImg': moreImgUrls, // camelCase
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // --- FEATURE: REAL-TIME ANIMAL STREAM ---
  Stream<List<Animal>> streamAnimals({String? category}) {
    Query query = _db.collection('animals').orderBy('createdAt', descending: true);

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Animal.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}