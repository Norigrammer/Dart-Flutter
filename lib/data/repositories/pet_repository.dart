import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/pet.dart';

class PetRepository {
  PetRepository(this._firestore, this._auth);
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _col => _firestore.collection('pets');

  String get _uid => _auth.currentUser!.uid;

  Stream<List<Pet>> watchMyPets() {
    return _col.where('members', arrayContains: _uid).snapshots().map(
          (snap) => snap.docs
              .map((d) => Pet.fromJson({...d.data(), 'id': d.id}))
              .toList(),
        );
  }

  Future<Pet> createPet({required String name}) async {
    final now = DateTime.now().toUtc();
    final doc = _col.doc();
    final pet = Pet(
      id: doc.id,
      name: name,
      members: [_uid],
      createdAt: now,
      updatedAt: now,
    );
    await doc.set({
      'name': pet.name,
      'members': pet.members,
      'createdAt': pet.createdAt,
      'updatedAt': pet.updatedAt,
      'photoUrl': pet.photoUrl,
    });
    return pet;
  }

  Future<void> updatePet(Pet pet, {String? name, String? photoUrl, List<String>? members}) async {
    _assertMember(pet);
    final updated = {
      if (name != null) 'name': name,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (members != null) 'members': members,
      'updatedAt': DateTime.now().toUtc(),
    };
    await _col.doc(pet.id).update(updated);
  }

  Future<void> deletePet(Pet pet) async {
    _assertMember(pet);
    await _col.doc(pet.id).delete();
    // NOTE: care_logs サブコレクションの削除は Cloud Functions でトリガー/バッチ削除推奨
  }

  void _assertMember(Pet pet) {
    if (!pet.members.contains(_uid)) {
      throw StateError('権限がありません');
    }
  }
}

final petRepositoryProvider = Provider<PetRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  return PetRepository(firestore, auth);
});

final myPetsStreamProvider = StreamProvider.autoDispose<List<Pet>>((ref) {
  final repo = ref.watch(petRepositoryProvider);
  return repo.watchMyPets();
});
