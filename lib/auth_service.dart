import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign Up
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Returns error message to display in UI
    }
  }

  // Login
  Future<String?> logIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
  //reset password
Future<void> resetPassword(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    // Notify the user to check their inbox
    print("Password reset email sent!");
  } on FirebaseAuthException catch (e) {
    // Handle specific errors (e.g., user not found)
    print("Error: ${e.message}");
    rethrow;
  }
}
  // Logout
  Future<void> logOut() async => await _auth.signOut();
}