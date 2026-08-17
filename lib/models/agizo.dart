import 'package:cloud_firestore/cloud_firestore.dart';

class AgizoModel {
  final String id;
  final String dukaId;
  final String mtejaMjina;
  final String mtejaSimu;
  final String mtejaAnwani;
  final List<AgizoItem> bidhaa;
  final double jumla;
  final String hali; // inasubiri, inashughulikiwa, imepelekwa, imefikia, imefutwa
  final String? maelezo;
  final DateTime iliyoundwa;
  final DateTime iliyosasishwa;

  AgizoModel({
    required this.id,
    required this.dukaId,
    required this.mtejaMjina,
    required this.mtejaSimu,
    required this.mtejaAnwani,
    required this.bidhaa,
    required this.jumla,
    required this.hali,
    this.maelezo,
    required this.iliyoundwa,
    required this.iliyosasishwa,
  });

  factory AgizoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AgizoModel(
      id: doc.id,
      dukaId: data['dukaId'] ?? '',
      mtejaMjina: data['mtejaMjina'] ?? '',
      mtejaSimu: data['mtejaSimu'] ?? '',
      mtejaAnwani: data['mtejaAnwani'] ?? '',
      bidhaa: (data['bidhaa'] as List<dynamic>? ?? [])
          .map((item) => AgizoItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      jumla: (data['jumla'] ?? 0).toDouble(),
      hali: data['hali'] ?? 'inasubiri',
      maelezo: data['maelezo'],
      iliyoundwa: (data['iliyoundwa'] as Timestamp).toDate(),
      iliyosasishwa: (data['iliyosasishwa'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dukaId': dukaId,
      'mtejaMjina': mtejaMjina,
      'mtejaSimu': mtejaSimu,
      'mtejaAnwani': mtejaAnwani,
      'bidhaa': bidhaa.map((item) => item.toMap()).toList(),
      'jumla': jumla,
      'hali': hali,
      if (maelezo != null) 'maelezo': maelezo,
      'iliyoundwa': Timestamp.fromDate(iliyoundwa),
      'iliyosasishwa': Timestamp.fromDate(iliyosasishwa),
    };
  }

  AgizoModel copyWith({String? hali, String? maelezo}) {
    return AgizoModel(
      id: id,
      dukaId: dukaId,
      mtejaMjina: mtejaMjina,
      mtejaSimu: mtejaSimu,
      mtejaAnwani: mtejaAnwani,
      bidhaa: bidhaa,
      jumla: jumla,
      hali: hali ?? this.hali,
      maelezo: maelezo ?? this.maelezo,
      iliyoundwa: iliyoundwa,
      iliyosasishwa: DateTime.now(),
    );
  }
}

class AgizoItem {
  final String bidhaaId;
  final String bidhaaJina;
  final String? bidhaapicha;
  final double bei;
  final int idadi;

  AgizoItem({
    required this.bidhaaId,
    required this.bidhaaJina,
    this.bidhaapicha,
    required this.bei,
    required this.idadi,
  });

  double get jumla => bei * idadi;

  factory AgizoItem.fromMap(Map<String, dynamic> map) {
    return AgizoItem(
      bidhaaId: map['bidhaaId'] ?? '',
      bidhaaJina: map['bidhaaJina'] ?? '',
      bidhaapicha: map['bidhaapicha'],
      bei: (map['bei'] ?? 0).toDouble(),
      idadi: map['idadi'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bidhaaId': bidhaaId,
      'bidhaaJina': bidhaaJina,
      if (bidhaapicha != null) 'bidhaapicha': bidhaapicha,
      'bei': bei,
      'idadi': idadi,
    };
  }
}
