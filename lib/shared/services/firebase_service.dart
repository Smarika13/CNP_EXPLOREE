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