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
  final String mainImg;
  final List<String> moreImg;
  final String description;
  final String? category; // Added for filtering consistency
  final String? diet;     // Added for filtering consistency

  Animal({
    required this.id,
    required this.name,
    required this.status,
    required this.mainImg,
    required this.moreImg,
    required this.description,
    this.category,
    this.diet,
  });

  factory Animal.fromFirestore(Map<String, dynamic> data, String docId) {
    return Animal(
      id: docId,
      name: data['name'] ?? 'Unknown Species',
      status: data['status'] ?? 'Vulnerable',
      mainImg: data['Mainimg'] ?? '',
      moreImg: List<String>.from(data['Moreimg'] ?? []),
      description: data['descriptions'] ?? 'No description available.',
      category: data['category'],
      diet: data['diet'],
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

      // 1. Start all uploads in parallel for speed
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

      // 2. Wait for all links to return
      String mainImgUrl = await mainImgTask;
      List<String> moreImgUrls = await Future.wait(galleryTasks);

      // 3. Save reference to Firestore
      await _db.collection('animals').add({
        'name': name,
        'status': status,
        'descriptions': description,
        'category': category,
        'diet': diet,
        'Mainimg': mainImgUrl,
        'Moreimg': moreImgUrls,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print("Upload complete!");
    } catch (e) {
      print("Upload Error: $e");
      rethrow;
    }
  }

  // --- FEATURE: REAL-TIME ANIMAL STREAM ---
  Stream<List<Animal>> streamAnimals({
    String? category,
    String? status,
    String? diet,
  }) {
    Query query = _db.collection('animals');

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }
    if (diet != null && diet.isNotEmpty) {
      query = query.where('diet', isEqualTo: diet);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Animal.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // --- FEATURE: BOOKING ---
  Future<String?> createRideBooking({
    required String animalId,
    required String userId,
    required double price,
  }) async {
    try {
      DocumentReference ref = await _db.collection('bookings').add({
        'animalId': animalId,
        'userId': userId,
        'amount': price,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      print("Booking Error: $e");
      return null;
    }
  }
}