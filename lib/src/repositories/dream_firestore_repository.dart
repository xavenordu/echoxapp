import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echoxapp/src/models/dream_entry.dart';

class DreamFirestoreRepository {
  final FirebaseFirestore firestore;

  DreamFirestoreRepository(this.firestore);

  CollectionReference get _col => firestore.collection('dreams');

  Future<void> addOrUpdateDream(DreamEntry entry) async {
    await _col.doc(entry.id).set(entry.toMap(), SetOptions(merge: true));
  }

  Future<List<DreamEntry>> fetchDreams() async {
    final snap = await _col.orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => DreamEntry.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();
  }

  Future<void> deleteDream(String id) async {
    await _col.doc(id).delete();
  }

  Stream<List<DreamEntry>> watchDreams() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => DreamEntry.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }
}
