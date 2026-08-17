import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../models/bidhaa.dart';
import '../utils/constants.dart';

final bidhaaServiceProvider =
    Provider<BidhaaService>((ref) => BidhaaService());

// Provider kwa idadi ya bidhaa
final bidhaaCountProvider = StreamProvider<int>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection(AppConstants.bidhaaCollection)
      .where('dukaId',
          isEqualTo: FirebaseAuth.instance.currentUser?.uid)
      .snapshots()
      .map((snap) => snap.docs.length);
});

// Provider kwa bidhaa zote za duka hili
final bidhaaListProvider = StreamProvider<List<BidhaaModel>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection(AppConstants.bidhaaCollection)
      .where('dukaId', isEqualTo: uid)
      .orderBy('iliyoundwa', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((doc) => BidhaaModel.fromFirestore(doc)).toList());
});

class BidhaaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  /// Ongeza bidhaa mpya
  Future<void> ongezaBidhaa(BidhaaModel bidhaa) async {
    await _db.collection(AppConstants.bidhaaCollection).add(bidhaa.toFirestore());
  }

  /// Sasisha bidhaa
  Future<void> sasakishaBidhaa(String id, Map<String, dynamic> data) async {
    data['iliyosasishwa'] = Timestamp.now();
    await _db
        .collection(AppConstants.bidhaaCollection)
        .doc(id)
        .update(data);
  }

  /// Futa bidhaa
  Future<void> futaBidhaa(String id) async {
    await _db.collection(AppConstants.bidhaaCollection).doc(id).delete();
  }

  /// Pakia picha ya bidhaa kwenye Firebase Storage
  Future<String> pakiaPicha(File picha, String bidhaaId) async {
    final ref = _storage.ref().child(
        '${AppConstants.bidhaaImagesPath}/$_uid/$bidhaaId/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await ref.putFile(picha);
    return await task.ref.getDownloadURL();
  }

  /// Futa picha kutoka Storage
  Future<void> futaPicha(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {}
  }

  /// Pata bidhaa moja
  Future<BidhaaModel?> getBidhaa(String id) async {
    final doc =
        await _db.collection(AppConstants.bidhaaCollection).doc(id).get();
    if (!doc.exists) return null;
    return BidhaaModel.fromFirestore(doc);
  }
}
