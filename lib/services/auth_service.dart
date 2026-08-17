import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mtumiaji.dart';
import '../utils/constants.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Stream ya mtumiaji wa sasa kutoka Firestore (real-time)
final mtumiajiStreamProvider = StreamProvider<MtumiajiModel?>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection(AppConstants.usersCollection)
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? MtumiajiModel.fromFirestore(doc) : null);
});

/// Stream ya duka la mtumiaji wa sasa (real-time)
final dukaStreamProvider = StreamProvider<DukaModel?>((ref) {
  final mtumiaji = ref.watch(mtumiajiStreamProvider).value;
  if (mtumiaji == null) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection(AppConstants.maduka)
      .doc(mtumiaji.dukaId)
      .snapshots()
      .map((doc) => doc.exists ? DukaModel.fromFirestore(doc) : null);
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get mtumiaji => _auth.currentUser;
  Stream<User?> get haliStream => _auth.authStateChanges();

  /// Ingia kwa barua pepe na neno la siri
  Future<String?> ingia({
    required String barua,
    required String neno,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: barua,
        password: neno,
      );
      return null; // Mafanikio
    } on FirebaseAuthException catch (e) {
      return _tafsiriKosa(e.code);
    } catch (e) {
      return 'Hitilafu imetokea. Jaribu tena.';
    }
  }

  /// Jisajili mtumiaji mpya na kuunda duka
  Future<String?> jisajili({
    required String jina,
    required String barua,
    required String simu,
    required String jinalaDuka,
    required String neno,
  }) async {
    try {
      // 1. Unda akaunti ya Firebase Auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email: barua,
        password: neno,
      );
      final uid = cred.user!.uid;

      // 2. Unda duka kwanza
      final dukaRef = _db.collection(AppConstants.maduka).doc();
      final dukaId = dukaRef.id;

      // 3. Unda rekodi ya mtumiaji na duka kwa wakati mmoja
      final batch = _db.batch();

      batch.set(_db.collection(AppConstants.usersCollection).doc(uid), {
        'jina': jina,
        'barua': barua,
        'simu': simu,
        'dukaId': dukaId,
        'iliyoundwa': Timestamp.now(),
      });

      batch.set(dukaRef, {
        'mmilikiId': uid,
        'jina': jinalaDuka,
        'rangiKuu': '#00C853',
        'imefunguliwa': true,
        'iliyoundwa': Timestamp.now(),
      });

      await batch.commit();

      // 4. Sasisha jina la display kwenye Firebase Auth
      await cred.user!.updateDisplayName(jina);

      return null; // Mafanikio
    } on FirebaseAuthException catch (e) {
      return _tafsiriKosa(e.code);
    } catch (e) {
      return 'Hitilafu imetokea. Jaribu tena.';
    }
  }

  /// Toka kwenye akaunti
  Future<void> toka() async {
    await _auth.signOut();
  }

  /// Sasisha data ya mtumiaji kwenye Firestore
  Future<void> sasishaMtumiaji(Map<String, dynamic> data) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _db.collection(AppConstants.usersCollection).doc(uid).update(data);
  }

  /// Tafsiri makosa ya Firebase Auth kwa Kiswahili
  String _tafsiriKosa(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Akaunti haikupatikana. Jisajili kwanza.';
      case 'wrong-password':
        return 'Neno la siri si sahihi.';
      case 'email-already-in-use':
        return 'Barua pepe hii tayari inatumika.';
      case 'weak-password':
        return 'Neno la siri ni dhaifu sana.';
      case 'invalid-email':
        return 'Barua pepe si sahihi.';
      case 'too-many-requests':
        return 'Majaribio mengi sana. Subiri kidogo.';
      case 'network-request-failed':
        return 'Hakuna muunganiko wa mtandao.';
      default:
        return 'Hitilafu imetokea. Jaribu tena.';
    }
  }
}
