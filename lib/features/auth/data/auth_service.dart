// Direct interaction with Firebase for authentication and user data initialization.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthService(this._firebaseAuth, this._firestore);

  // get the current user
  User? currentUser() {
    return _firebaseAuth.currentUser;
  }

  // create user with firebase_auth
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
              email: email.trim(), password: password.trim());
      // Initialize user data in Firestore
      await _initializeUserData(userCredential.user);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  // initialize user collection in firestore
  Future<void> _initializeUserData(User? user) async {
    if (user == null) return;

    String email = user.email ?? 'Anonymous';
    String photoURL = user.photoURL ?? '';

    DocumentReference userDocRef = _firestore.collection('users').doc(user.uid);
    print(userDocRef);

    // Firestore user data initialization
    await userDocRef.set({
      'email': email,
      'photoURL': photoURL,
      'dietaryPreferences': [],
      'allergies': [],
      'macronutrients': [],
      'micronutrients': [],
      'pantryEssentials': [],
      'meat': [],
      'vegetables': []
    });
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
              email: email.trim(), password: password.trim());
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Stream to listen to user authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
