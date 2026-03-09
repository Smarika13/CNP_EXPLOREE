import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. SEED DATA: Populates the "activities" collection for the Explore Page
  Future<void> seedInitialData() async {
    try {
      final List<Map<String, dynamic>> activities = [
        {'name': 'Jeep Safari', 'iconName': 'directions_car'},
        {'name': 'Canoe Ride', 'iconName': 'directions_boat'},
        {'name': 'Jungle Walk', 'iconName': 'directions_walk'},
        {'name': 'Elephant Safari', 'iconName': 'eco'}, // Added a new one for variety
      ];

      for (var activity in activities) {
        // Using the name as the Document ID avoids duplicates
        await _db.collection('activities').doc(activity['name']).set(activity);
      }
      print("Database Setup: Activities seeded successfully!");
    } catch (e) {
      print("Seeding Error: $e");
    }
    await seedGuides();
  }

  // 2. SEED GUIDES: Populates the "guides" collection (runs once, skips existing)
  Future<void> seedGuides() async {
    try {
      final existing = await _db.collection('guides').limit(1).get();
      if (existing.docs.isNotEmpty) return; // already seeded

      final List<Map<String, dynamic>> guides = [
        {'name': 'Ram Bahadur Tharu',     'phone': '9845001001', 'isActive': true, 'totalAssignments': 0},
        {'name': 'Sita Kumari Chaudhary', 'phone': '9845001002', 'isActive': true, 'totalAssignments': 0},
        {'name': 'Hari Prasad Gurung',    'phone': '9845001003', 'isActive': true, 'totalAssignments': 0},
        {'name': 'Kamala Devi Tamang',    'phone': '9845001004', 'isActive': true, 'totalAssignments': 0},
        {'name': 'Bikram Singh Magar',    'phone': '9845001005', 'isActive': true, 'totalAssignments': 0},
        {'name': 'Sunita Rai',            'phone': '9845001006', 'isActive': true, 'totalAssignments': 0},
        {'name': 'Deepak Adhikari',       'phone': '9845001007', 'isActive': true, 'totalAssignments': 0},
        {'name': 'Gopal Praja',           'phone': '9845001008', 'isActive': true, 'totalAssignments': 0},
        {'name': 'Sarita Praja',          'phone': '9845001009', 'isActive': true, 'totalAssignments': 0},
        {'name': 'Mohan Chepang',         'phone': '9845001010', 'isActive': true, 'totalAssignments': 0},
        {'name': 'Anita Shrestha',        'phone': '9845001011', 'isActive': true, 'totalAssignments': 0},
        {'name': 'Prakash Oli',           'phone': '9845001012', 'isActive': true, 'totalAssignments': 0},
        {'name': 'Puja Karki',            'phone': '9845001013', 'isActive': true, 'totalAssignments': 0},
        {'name': 'Nabin Lama',            'phone': '9845001014', 'isActive': true, 'totalAssignments': 0},
        {'name': 'Rekha Bista',           'phone': '9845001015', 'isActive': true, 'totalAssignments': 0},
      ];

      for (var guide in guides) {
        await _db.collection('guides').add(guide);
      }
      print("Database Setup: Guides seeded successfully!");
    } catch (e) {
      print("Seeding Error (guides): $e");
    }
  }

  // 2. CREATE: Saves a new booking from the Explore Page
  Future<void> saveChitwanBooking(List<String> activities) async {
    try {
      await _db.collection('bookings').add({
        'parkName': 'Chitwan National Park',
        'activities': activities,
        'bookingDate': FieldValue.serverTimestamp(), // Firestore server time
        'status': 'Pending',
      });
    } catch (e) {
      throw Exception("Failed to save booking: $e");
    }
  }

  // 3. DELETE: Removes a booking by its Firestore Document ID
  Future<void> deleteBooking(String docId) async {
    try {
      await _db.collection('bookings').doc(docId).delete();
    } catch (e) {
      throw Exception("Failed to delete booking: $e");
    }
  }

  // 4. SEED SPECIES: Seeds species from local dart data into Firestore (once per category)
  Future<void> seedSpeciesForCategory(String category, List<Map<String, dynamic>> speciesList) async {
    final existing = await _db
        .collection('species')
        .where('category', isEqualTo: category)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return; // already seeded

    final batch = _db.batch();
    for (final sp in speciesList) {
      final ref = _db.collection('species').doc();
      batch.set(ref, sp);
    }
    await batch.commit();
  }

  Stream<QuerySnapshot> streamSpeciesByCategory(String category) {
    // No orderBy to avoid requiring a composite index — sort in UI code
    return _db
        .collection('species')
        .where('category', isEqualTo: category)
        .snapshots();
  }

  Future<void> addSpecies(Map<String, dynamic> data) async {
    await _db.collection('species').add(data);
  }

  Future<void> updateSpecies(String docId, Map<String, dynamic> data) async {
    await _db.collection('species').doc(docId).update(data);
  }

  Future<void> deleteSpecies(String docId) async {
    await _db.collection('species').doc(docId).delete();
  }

  // 5. SEED CATEGORIES: Populates the "categories" collection (runs once)
  Future<void> seedCategories() async {
    try {
      final existing = await _db.collection('categories').limit(1).get();
      if (existing.docs.isNotEmpty) return; // already seeded

      final List<Map<String, dynamic>> categories = [
        {'name': 'Mammal',     'type': 'fauna', 'order': 1, 'isActive': true},
        {'name': 'Bird',       'type': 'fauna', 'order': 2, 'isActive': true},
        {'name': 'Fish',       'type': 'fauna', 'order': 3, 'isActive': true},
        {'name': 'Reptile',    'type': 'fauna', 'order': 4, 'isActive': true},
        {'name': 'Amphibian',  'type': 'fauna', 'order': 5, 'isActive': true},
        {'name': 'Butterfly',  'type': 'fauna', 'order': 6, 'isActive': true},
        {'name': 'Plant',      'type': 'flora', 'order': 7, 'isActive': true},
        {'name': 'Butterfly',  'type': 'flora', 'order': 8, 'isActive': true},
      ];

      for (var cat in categories) {
        await _db.collection('categories').add(cat);
      }
      print("Database Setup: Categories seeded successfully!");
    } catch (e) {
      print("Seeding Error (categories): $e");
    }
  }

  // 5. CATEGORIES CRUD
  Stream<QuerySnapshot> streamCategories() {
    return _db.collection('categories').orderBy('order').snapshots();
  }

  Future<void> addCategory(String name, String type, int order) async {
    await _db.collection('categories').add({
      'name': name,
      'type': type,
      'order': order,
      'isActive': true,
    });
  }

  Future<void> updateCategory(String docId, String name, String type) async {
    await _db.collection('categories').doc(docId).update({
      'name': name,
      'type': type,
    });
  }

  Future<void> toggleCategoryActive(String docId, bool isActive) async {
    await _db.collection('categories').doc(docId).update({'isActive': isActive});
  }

  Future<void> deleteCategory(String docId) async {
    await _db.collection('categories').doc(docId).delete();
  }
}