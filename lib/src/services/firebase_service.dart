import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  // Firebase Auth instance
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Use the conventional name `firestore` so callers (repositories) can access it
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // A simple singleton instance for convenience when using providers
  FirebaseService._internal();
  static final FirebaseService instance = FirebaseService._internal();

  // Call this after you set up auth or for anonymous sign-in
  Future<User?> ensureSignedInAnonymously() async {
    if (auth.currentUser != null) return auth.currentUser;
    final cred = await auth.signInAnonymously();
    return cred.user;
  }

  // Example: save dream entry
  Future<void> saveDream(String userId, Map<String, dynamic> dreamData) async {
    await firestore.collection('users').doc(userId).collection('dreams').add(dreamData);
  }

  // Example: fetch recent dreams
  Stream<QuerySnapshot> streamDreams(String userId) {
    return firestore.collection('users').doc(userId).collection('dreams').orderBy('createdAt', descending: true).snapshots();
  }

  // Add functions for messages, reflections, scheduling delayed responses, etc.
}
