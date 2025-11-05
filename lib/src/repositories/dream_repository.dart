import 'package:echoxapp/src/models/dream_entry.dart';
import 'package:echoxapp/src/services/firebase_service.dart';

class DreamRepository {
  final FirebaseService firebaseService;

  DreamRepository({required this.firebaseService});

  Future<List<DreamEntry>> fetchDreams() async {
    final snap = await firebaseService.firestore
        .collection('dreams')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => DreamEntry.fromMap(d.data(), d.id))
        .toList();
  }

  Future<void> addDream(DreamEntry entry) async {
    await firebaseService.firestore.collection('dreams').add(entry.toMap());
  }
}
