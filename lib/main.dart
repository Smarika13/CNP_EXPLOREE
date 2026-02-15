import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'auth_wrapper.dart'; // Make sure this file exists
import 'firebase_options.dart';
import 'shared/services/firebase_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firebaseService = FirebaseService();
  try {
    await firebaseService.seedInitialData(); 
    print("Firebase: Chitwan activities are ready!");
  } catch (e) {
    print("Firebase Setup Error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CNP Navigator',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      // Starts with Splash, which then moves to AuthWrapper
      home: const SplashScreen(), 
    );
  }
}