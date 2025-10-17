import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/care_log.dart';

class CareLogRepository {
  CareLogRepository(this._firestore, this._auth, this._storage);
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> _logsCol(String petId) =>
      _firestore.collection('pets').doc(petId).collection('logs');

  Future<String> generateLogId(String petId) async {
    return _logsCol(petId).doc().id;
  }

  Stream<List<CareLog>> watchLogs(String petId, {int limit = 100}) {
    return _logsCol(petId)
        .orderBy('at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CareLog.fromJson({...d.data(), 'id': d.id, 'petId': petId}))
            .toList());
  }

  Future<CareLog> addLog({
    required String petId,
    required CareLogType type,
    DateTime? at,
    String? note,
    String? photoUrl,
  }) async {
    final now = DateTime.now().toUtc();
    final doc = _logsCol(petId).doc();
    final log = CareLog(
      id: doc.id,
      petId: petId,
      type: type,
      note: note,
      photoUrl: photoUrl,
      at: (at ?? now),
      createdBy: _uid,
      createdAt: now,
    );
    await doc.set({
      'type': log.type.name,
      'note': log.note,
      'photoUrl': log.photoUrl,
      'at': log.at,
      'createdBy': log.createdBy,
      'createdAt': log.createdAt,
    });
    return log;
  }

  Future<CareLog> addLogWithId({
    required String petId,
    required String id,
    required CareLogType type,
    DateTime? at,
    String? note,
    String? photoUrl,
  }) async {
    final now = DateTime.now().toUtc();
    final doc = _logsCol(petId).doc(id);
    final log = CareLog(
      id: id,
      petId: petId,
      type: type,
      note: note,
      photoUrl: photoUrl,
      at: (at ?? now),
      createdBy: _uid,
      createdAt: now,
    );
    await doc.set({
      'type': log.type.name,
      'note': log.note,
      'photoUrl': log.photoUrl,
      'at': log.at,
      'createdBy': log.createdBy,
      'createdAt': log.createdAt,
    });
    return log;
  }

  Future<void> updateLog(
    String petId,
    CareLog log, {
    String? note,
    String? photoUrl,
    CareLogType? type,
    DateTime? at,
    bool removePhoto = false,
  }) async {
    final updated = <String, dynamic>{
      if (note != null) 'note': note,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (type != null) 'type': type.name,
      if (at != null) 'at': at,
      if (removePhoto) 'photoUrl': FieldValue.delete(),
    };
    if (updated.isEmpty) return;
    await _logsCol(petId).doc(log.id).update(updated);
  }

  Future<void> deleteLog(String petId, CareLog log) async {
    await _logsCol(petId).doc(log.id).delete();
  }

  Future<String> uploadLogPhoto({
    required String petId,
    required String logId,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
    String fileExtension = 'jpg',
    void Function(double progress)? onProgress,
  }) async {
    final ref = _storage.ref().child('pets/$petId/logs/$logId.$fileExtension');
    final uploadTask = ref.putData(bytes, SettableMetadata(contentType: contentType));
    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((event) {
        final total = event.totalBytes;
        if (total > 0) {
          onProgress(event.bytesTransferred / total);
        }
      });
    }
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteLogPhoto({
    required String petId,
    required String logId,
    String fileExtension = 'jpg',
  }) async {
    final ref = _storage.ref().child('pets/$petId/logs/$logId.$fileExtension');
    await ref.delete();
  }
}

final careLogRepositoryProvider = Provider<CareLogRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;
  return CareLogRepository(firestore, auth, storage);
});

final petLogsProvider = StreamProvider.autoDispose.family<List<CareLog>, String>((ref, petId) {
  final repo = ref.watch(careLogRepositoryProvider);
  return repo.watchLogs(petId);
});
