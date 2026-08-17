import 'package:cloud_firestore/cloud_firestore.dart';

class BidhaaModel {
  final String id;
  final String dukaId;
  final String jina;
  final String maelezo;
  final double bei;
  final double? beiAsili;     // Bei ya awali (kama kuna punguzo)
  final int idadi;            // Stock quantity
  final String kategoria;
  final List<String> picha;   // Image URLs
  final bool inapatikana;
  final int mauzo;            // Total units sold
  final DateTime iliyoundwa;
  final DateTime iliyosasishwa;

  BidhaaModel({
    required this.id,
    required this.dukaId,
    required this.jina,
    required this.maelezo,
    required this.bei,
    this.beiAsili,
    required this.idadi,
    required this.kategoria,
    required this.picha,
    this.inapatikana = true,
    this.mauzo = 0,
    required this.iliyoundwa,
    required this.iliyosasishwa,
  });

  bool get inaPunguzo => beiAsili != null && beiAsili! > bei;

  double get asilimiaYaPunguzo {
    if (!inaPunguzo) return 0;
    return ((beiAsili! - bei) / beiAsili! * 100);
  }

  String get pichaKuu => picha.isNotEmpty ? picha[0] : '';

  factory BidhaaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BidhaaModel(
      id: doc.id,
      dukaId: data['dukaId'] ?? '',
      jina: data['jina'] ?? '',
      maelezo: data['maelezo'] ?? '',
      bei: (data['bei'] ?? 0).toDouble(),
      beiAsili: data['beiAsili'] != null
          ? (data['beiAsili']).toDouble()
          : null,
      idadi: data['idadi'] ?? 0,
      kategoria: data['kategoria'] ?? 'Nyingine',
      picha: List<String>.from(data['picha'] ?? []),
      inapatikana: data['inapatikana'] ?? true,
      mauzo: data['mauzo'] ?? 0,
      iliyoundwa: (data['iliyoundwa'] as Timestamp).toDate(),
      iliyosasishwa: (data['iliyosasishwa'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dukaId': dukaId,
      'jina': jina,
      'maelezo': maelezo,
      'bei': bei,
      if (beiAsili != null) 'beiAsili': beiAsili,
      'idadi': idadi,
      'kategoria': kategoria,
      'picha': picha,
      'inapatikana': inapatikana,
      'mauzo': mauzo,
      'iliyoundwa': Timestamp.fromDate(iliyoundwa),
      'iliyosasishwa': Timestamp.fromDate(iliyosasishwa),
    };
  }

  BidhaaModel copyWith({
    String? jina,
    String? maelezo,
    double? bei,
    double? beiAsili,
    int? idadi,
    String? kategoria,
    List<String>? picha,
    bool? inapatikana,
    int? mauzo,
  }) {
    return BidhaaModel(
      id: id,
      dukaId: dukaId,
      jina: jina ?? this.jina,
      maelezo: maelezo ?? this.maelezo,
      bei: bei ?? this.bei,
      beiAsili: beiAsili ?? this.beiAsili,
      idadi: idadi ?? this.idadi,
      kategoria: kategoria ?? this.kategoria,
      picha: picha ?? this.picha,
      inapatikana: inapatikana ?? this.inapatikana,
      mauzo: mauzo ?? this.mauzo,
      iliyoundwa: iliyoundwa,
      iliyosasishwa: DateTime.now(),
    );
  }
}
