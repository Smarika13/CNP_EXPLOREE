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
        // Jeep Safari + Jungle Walk specialists
        {'name': 'Ram Bahadur Tharu',    'phone': '9845001001', 'isActive': true, 'totalAssignments': 0, 'specializations': ['Jeep Safari', 'Jungle Walk']},
        {'name': 'Sita Kumari Chaudhary','phone': '9845001002', 'isActive': true, 'totalAssignments': 0, 'specializations': ['Jeep Safari', 'Jungle Walk']},
        {'name': 'Hari Prasad Gurung',   'phone': '9845001003', 'isActive': true, 'totalAssignments': 0, 'specializations': ['Jeep Safari', 'Bird Watching']},
        {'name': 'Kamala Devi Tamang',   'phone': '9845001004', 'isActive': true, 'totalAssignments': 0, 'specializations': ['Jeep Safari', 'Canoe Ride']},
        {'name': 'Bikram Singh Magar',   'phone': '9845001005', 'isActive': true, 'totalAssignments': 0, 'specializations': ['Jeep Safari', 'Canoe Ride']},
        // Canoe Ride specialists
        {'name': 'Sunita Rai',           'phone': '9845001006', 'isActive': true, 'totalAssignments': 0, 'specializations': ['Canoe Ride', 'Bird Watching']},
        {'name': 'Deepak Adhikari',      'phone': '9845001007', 'isActive': true, 'totalAssignments': 0, 'specializations': ['Canoe Ride', 'Jungle Walk']},
        // Elephant Safari specialists (mahout guides)
        {'name': 'Gopal Praja',          'phone': '9845001008', 'isActive': true, 'totalAssignments': 0, 'specializations': ['Elephant Safari']},
        {'name': 'Sarita Praja',         'phone': '9845001009', 'isActive': true, 'totalAssignments': 0, 'specializations': ['Elephant Safari']},
        {'name': 'Mohan Chepang',        'phone': '9845001010', 'isActive': true, 'totalAssignments': 0, 'specializations': ['Elephant Safari']},
        // Bird Watching + Jungle Walk specialists
        {'name': 'Anita Shrestha',       'phone': '9845001011', 'isActive': true, 'totalAssignments': 0, 'specializations': ['Bird Watching', 'Jungle Walk']},
        {'name': 'Prakash Oli',          'phone': '9845001012', 'isActive': true, 'totalAssignments': 0, 'specializations': ['Bird Watching', 'Jungle Walk']},
        {'name': 'Puja Karki',           'phone': '9845001013', 'isActive': true, 'totalAssignments': 0, 'specializations': ['Bird Watching', 'Jungle Walk']},
        // Multi-activity guides
        {'name': 'Nabin Lama',           'phone': '9845001014', 'isActive': true, 'totalAssignments': 0, 'specializations': ['Jeep Safari', 'Bird Watching', 'Jungle Walk']},
        {'name': 'Rekha Bista',          'phone': '9845001015', 'isActive': true, 'totalAssignments': 0, 'specializations': ['Canoe Ride', 'Bird Watching', 'Jungle Walk']},
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
}