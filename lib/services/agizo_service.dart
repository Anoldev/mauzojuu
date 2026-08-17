import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/agizo.dart';
import '../utils/constants.dart';

final agizoServiceProvider =
    Provider<AgizoService>((ref) => AgizoService());

// Stats za dashboard
final maagizoStatsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection(AppConstants.maagizaCollection)
      .where('dukaId', isEqualTo: uid)
      .snapshots()
      .map((snap) {
    final maagizo =
        snap.docs.map((doc) => AgizoModel.fromFirestore(doc)).toList();

    final sasa = DateTime.now();
    final mwanzoWaLeo = DateTime(sasa.year, sasa.month, sasa.day);
    final mwanzoWaMwezi = DateTime(sasa.year, sasa.month, 1);

    double mauzoLeo = 0;
    double mauzoMwezi = 0;
    int yanayosubiri = 0;
    int zimefika = 0;

    for (final agizo in maagizo) {
      if (agizo.hali == AppConstants.orderDelivered) {
        if (agizo.iliyoundwa.isAfter(mwanzoWaLeo)) {
          mauzoLeo += agizo.jumla;
        }
        if (agizo.iliyoundwa.isAfter(mwanzoWaMwezi)) {
          mauzoMwezi += agizo.jumla;
        }
        zimefika++;
      }
      if (agizo.hali == AppConstants.orderPending) {
        yanayosubiri++;
      }
    }

    return {
      'mauzoLeo': mauzoLeo,
      'mauzoMwezi': mauzoMwezi,
      'maagizaYote': maagizo.length,
      'yanayosubiri': yanayosubiri,
      'zimefika': zimefika,
    };
  });
});

// Orodha ya maagizo
final maagizoListProvider = StreamProvider<List<AgizoModel>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection(AppConstants.maagizaCollection)
      .where('dukaId', isEqualTo: uid)
      .orderBy('iliyoundwa', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((doc) => AgizoModel.fromFirestore(doc)).toList());
});

class AgizoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Sasisha hali ya agizo
  Future<void> sasakishaHali(String id, String haliMpya) async {
    await _db.collection(AppConstants.maagizaCollection).doc(id).update({
      'hali': haliMpya,
      'iliyosasishwa': Timestamp.now(),
    });
  }

  /// Ongeza agizo jipya
  Future<String> ongezaAgizo(AgizoModel agizo) async {
    final doc = await _db
        .collection(AppConstants.maagizaCollection)
        .add(agizo.toFirestore());
    return doc.id;
  }

  /// Futa agizo
  Future<void> futaAgizo(String id) async {
    await _db.collection(AppConstants.maagizaCollection).doc(id).delete();
  }
}
