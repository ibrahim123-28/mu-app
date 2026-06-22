import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Provider for the AuthService class
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// 2. Provider that watches if the user is logged in or out
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// 3. Provider that streams the user's Firestore profile data in real-time
final userProvider = StreamProvider<DocumentSnapshot?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user != null) {
    return ref.watch(authServiceProvider).getUserProfile(user.uid);
  }
  return const Stream.empty();
});


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ----- AUTHENTICATION ----- //

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception("Login Failed: ${e.toString()}");
    }
  }

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception("Sign Up Failed: ${e.toString()}");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ----- FIRESTORE DATABASE ----- //

  // Get real-time stream of the user's profile document
  Stream<DocumentSnapshot> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // Save or update user profile (called during onboarding)
  Future<void> saveUserCourseData(String course, String semester) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'course': course,
        'semester': semester,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // Fetch the massive course curriculum JSON for the Notes/Tests screens
  Future<Map<String, dynamic>?> getCourseCurriculum(String courseId) async {
    try {
      final doc = await _db.collection('courses').doc(courseId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print("Error fetching curriculum: $e");
      return null;
    }
  }
  Future<void> saveAcademicRecords(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user != null) {
      // SetOptions(merge: true) ensures we don't delete their course/semester!
      await _db.collection('users').doc(user.uid).set(data, SetOptions(merge: true));
    }
  }
  // Update the last studied topic
  Future<void> updateLastStudied(String subjectName, String topicName, double progress) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'last_studied': {
          'subject': subjectName,
          'topic': topicName,
          'progress': progress,
        }
      }, SetOptions(merge: true));
    }
  }
  // Save Planner Data (Exam Date, Tasks, Attendance)
  Future<void> savePlannerData(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'planner': data
      }, SetOptions(merge: true));
    }
  }
  // Save Resume Data
  Future<void> saveResumeData(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'resume': data
      }, SetOptions(merge: true));
    }
  }
}