import 'package:cloud_firestore/cloud_firestore.dart';

/// Model ya ujumbe mmoja kwenye mazungumzo ya AI
class UjumbeModel {
  final String id;
  final String maudhui;
  final bool niAI;
  final DateTime wakati;

  UjumbeModel({
    required this.id,
    required this.maudhui,
    required this.niAI,
    required this.wakati,
  });

  factory UjumbeModel.fromMap(Map<String, dynamic> map) {
    return UjumbeModel(
      id: map['id'] ?? '',
      maudhui: map['maudhui'] ?? '',
      niAI: map['niAI'] ?? false,
      wakati: map['wakati'] is Timestamp
          ? (map['wakati'] as Timestamp).toDate()
          : DateTime.parse(map['wakati'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'maudhui': maudhui,
      'niAI': niAI,
      'wakati': wakati.toIso8601String(),
    };
  }
}
