import 'package:cloud_firestore/cloud_firestore.dart';

class MtumiajiModel {
  final String id;
  final String jina;
  final String barua;
  final String? simu;
  final String? picha;
  final String dukaId;
  final DateTime iliyoundwa;

  MtumiajiModel({
    required this.id,
    required this.jina,
    required this.barua,
    this.simu,
    this.picha,
    required this.dukaId,
    required this.iliyoundwa,
  });

  factory MtumiajiModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MtumiajiModel(
      id: doc.id,
      jina: data['jina'] ?? '',
      barua: data['barua'] ?? '',
      simu: data['simu'],
      picha: data['picha'],
      dukaId: data['dukaId'] ?? '',
      iliyoundwa: (data['iliyoundwa'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'jina': jina,
      'barua': barua,
      if (simu != null) 'simu': simu,
      if (picha != null) 'picha': picha,
      'dukaId': dukaId,
      'iliyoundwa': Timestamp.fromDate(iliyoundwa),
    };
  }
}

class DukaModel {
  final String id;
  final String mmilikiId;
  final String jina;
  final String? maelezo;
  final String? logo;
  final String? banner;
  final String rangiKuu;
  final String? anwani;
  final String? simu;
  final String? barua;
  final bool imefunguliwa;
  final DateTime iliyoundwa;

  DukaModel({
    required this.id,
    required this.mmilikiId,
    required this.jina,
    this.maelezo,
    this.logo,
    this.banner,
    this.rangiKuu = '#00C853',
    this.anwani,
    this.simu,
    this.barua,
    this.imefunguliwa = true,
    required this.iliyoundwa,
  });

  factory DukaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DukaModel(
      id: doc.id,
      mmilikiId: data['mmilikiId'] ?? '',
      jina: data['jina'] ?? '',
      maelezo: data['maelezo'],
      logo: data['logo'],
      banner: data['banner'],
      rangiKuu: data['rangiKuu'] ?? '#00C853',
      anwani: data['anwani'],
      simu: data['simu'],
      barua: data['barua'],
      imefunguliwa: data['imefunguliwa'] ?? true,
      iliyoundwa: (data['iliyoundwa'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mmilikiId': mmilikiId,
      'jina': jina,
      if (maelezo != null) 'maelezo': maelezo,
      if (logo != null) 'logo': logo,
      if (banner != null) 'banner': banner,
      'rangiKuu': rangiKuu,
      if (anwani != null) 'anwani': anwani,
      if (simu != null) 'simu': simu,
      if (barua != null) 'barua': barua,
      'imefunguliwa': imefunguliwa,
      'iliyoundwa': Timestamp.fromDate(iliyoundwa),
    };
  }
}
