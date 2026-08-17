import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../models/mtumiaji.dart';
import '../utils/constants.dart';

final dukaServiceProvider = Provider<DukaService>((ref) => DukaService());

/// Stream ya duka la mtumiaji wa sasa (real-time)
final myDukaProvider = StreamProvider<DukaModel?>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection(AppConstants.usersCollection)
      .doc(uid)
      .snapshots()
      .asyncExpand((userDoc) {
    final dukaId = (userDoc.data() ?? {})['dukaId'] as String?;
    if (dukaId == null || dukaId.isEmpty) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection(AppConstants.maduka)
        .doc(dukaId)
        .snapshots()
        .map((doc) => doc.exists ? DukaModel.fromFirestore(doc) : null);
  });
});

class DukaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  /// Pata dukaId ya mtumiaji wa sasa
  Future<String?> getDukaId() async {
    final doc = await _db.collection(AppConstants.usersCollection).doc(_uid).get();
    return (doc.data() ?? {})['dukaId'] as String?;
  }

  /// Sasisha maelezo ya duka
  Future<void> sasishaDuka({
    required String dukaId,
    required Map<String, dynamic> data,
  }) async {
    data['iliyosasishwa'] = Timestamp.now();
    await _db.collection(AppConstants.maduka).doc(dukaId).update(data);
  }

  /// Pakia picha ya logo ya duka
  Future<String> pakiaLogo(File picha, String dukaId) async {
    final ref = _storage.ref().child(
        '${AppConstants.dukaImagesPath}/$dukaId/logo_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await ref.putFile(picha);
    final url = await task.ref.getDownloadURL();
    await _db.collection(AppConstants.maduka).doc(dukaId).update({'logo': url});
    return url;
  }

  /// Pakia picha ya banner ya duka
  Future<String> pakiaBanner(File picha, String dukaId) async {
    final ref = _storage.ref().child(
        '${AppConstants.dukaImagesPath}/$dukaId/banner_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await ref.putFile(picha);
    final url = await task.ref.getDownloadURL();
    await _db.collection(AppConstants.maduka).doc(dukaId).update({'banner': url});
    return url;
  }
}
