import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'auth_wrapper.dart';
import 'firebase_options.dart';
// 1. IMPORT your service file here
import 'shared/services/firebase_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. SEEDING LOGIC (The "Setup" step)
  // Create an instance of your service
  final firebaseService = FirebaseService();
  
  try {
    // This creates your activities in the database automatically via code
    // You can comment this line out after running the app successfully once
    await firebaseService.seedInitialData(); 
    print("Firebase: Chitwan activities are ready!");
  } catch (e) {
    print("Firebase Setup Error: $e");
  }

  runApp(const MaterialApp(home: AuthWrapper()));
}