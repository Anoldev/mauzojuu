import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';
import '../models/mazungumzo.dart';

// ─── WEKA API KEY YAKO HAPA ──────────────────────────────────────────────────
// Pata API key BURE kutoka: https://aistudio.google.com/app/apikey
const String _geminiApiKey = 'WEKA_API_KEY_YAKO_HAPA';
// ─────────────────────────────────────────────────────────────────────────────

const String _geminiUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_geminiApiKey';

final aiServiceProvider = Provider<AIService>((ref) => AIService());

/// Provider ya historia ya mazungumzo (kwa UI)
final mazungumzoProvider =
    StateNotifierProvider<MazungumzoNotifier, List<UjumbeModel>>(
        (ref) => MazungumzoNotifier());

class MazungumzoNotifier extends StateNotifier<List<UjumbeModel>> {
  MazungumzoNotifier() : super([]);

  void ongezaUjumbe(UjumbeModel ujumbe) {
    state = [...state, ujumbe];
  }

  void futa() {
    state = [];
  }
}

class AIService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  /// Pata muktadha kamili wa duka ili kumpa AI data halisi
  Future<String> _pataMuktadha() async {
    try {
      // 1. Data ya mtumiaji
      final mtumiajiDoc = await _db
          .collection(AppConstants.usersCollection)
          .doc(_uid)
          .get();
      final mtumiajiData = mtumiajiDoc.data() ?? {};
      final jina = mtumiajiData['jina'] ?? 'Mfanyabiashara';
      final dukaId = mtumiajiData['dukaId'] ?? '';

      // 2. Data ya duka
      String jinalaDuka = 'Duka';
      if (dukaId.isNotEmpty) {
        final dukaDoc =
            await _db.collection(AppConstants.maduka).doc(dukaId).get();
        jinalaDuka = dukaDoc.data()?['jina'] ?? 'Duka';
      }

      // 3. Bidhaa zote
      final bidhaaSnap = await _db
          .collection(AppConstants.bidhaaCollection)
          .where('dukaId', isEqualTo: _uid)
          .get();

      final bidhaaZote = bidhaaSnap.docs.map((doc) {
        final d = doc.data();
        return '- ${d['jina']} (Bei: TZS ${d['bei']}, Stock: ${d['idadi']}, Mauzo: ${d['mauzo'] ?? 0})';
      }).join('\n');

      final bidhaaZinazokwisha = bidhaaSnap.docs
          .where((doc) => (doc.data()['idadi'] ?? 0) <= 5)
          .map((doc) => '- ${doc.data()['jina']} (Stock: ${doc.data()['idadi']})')
          .join('\n');

      // 4. Maagizo
      final sasa = DateTime.now();
      final mwanzoLeo = DateTime(sasa.year, sasa.month, sasa.day);
      final mwanzoMwezi = DateTime(sasa.year, sasa.month, 1);

      final maagizoSnap = await _db
          .collection(AppConstants.maagizaCollection)
          .where('dukaId', isEqualTo: _uid)
          .get();

      double mauzoLeo = 0;
      double mauzoMwezi = 0;
      int yanayosubiri = 0;
      int zimefika = 0;
      int maagizaYote = maagizoSnap.docs.length;

      for (final doc in maagizoSnap.docs) {
        final d = doc.data();
        final tarehe = (d['iliyoundwa'] as Timestamp?)?.toDate() ?? DateTime.now();
        final hali = d['hali'] ?? '';
        final jumla = (d['jumla'] ?? 0).toDouble();

        if (hali == AppConstants.orderDelivered) {
          if (tarehe.isAfter(mwanzoLeo)) mauzoLeo += jumla;
          if (tarehe.isAfter(mwanzoMwezi)) mauzoMwezi += jumla;
          zimefika++;
        }
        if (hali == AppConstants.orderPending) yanayosubiri++;
      }

      return '''
=== MUKTADHA WA DUKA ===
Mmiliki: $jina
Jina la Duka: $jinalaDuka
Tarehe ya leo: ${sasa.day}/${sasa.month}/${sasa.year}

=== MAUZO ===
Mauzo ya Leo: TZS ${mauzoLeo.toStringAsFixed(0)}
Mauzo ya Mwezi Huu: TZS ${mauzoMwezi.toStringAsFixed(0)}

=== MAAGIZO ===
Maagizo Yote: $maagizaYote
Yanayosubiri: $yanayosubiri
Zimefika (Zilizokamilika): $zimefika

=== BIDHAA (${bidhaaSnap.docs.length} Zilizoorodheshwa) ===
${bidhaaZote.isNotEmpty ? bidhaaZote : 'Bado huna bidhaa zilizoorodheshwa'}

=== BIDHAA ZINAZOISHA (Stock ≤ 5) ===
${bidhaaZinazokwisha.isNotEmpty ? bidhaaZinazokwisha : 'Hakuna bidhaa zinazoisha kwa sasa'}
''';
    } catch (e) {
      return 'Muktadha haukupatikana kwa sababu ya hitilafu: $e';
    }
  }

  /// Tuma ujumbe kwa AI na pata jibu
  Future<String> ulizaAI({
    required String swali,
    required List<UjumbeModel> historia,
  }) async {
    if (_geminiApiKey == 'WEKA_API_KEY_YAKO_HAPA') {
      return '⚠️ Tafadhali weka Gemini API key yako kwenye faili `lib/services/ai_service.dart`. Pata API key bure kutoka: https://aistudio.google.com/app/apikey';
    }

    try {
      final muktadha = await _pataMuktadha();

      // Tengeneza historia ya mazungumzo kwa Gemini
      final List<Map<String, dynamic>> contents = [
        // System instruction kama ujumbe wa kwanza
        {
          'role': 'user',
          'parts': [
            {
              'text': '''Wewe ni MSAIDIZI WA BIASHARA wa akili bandia (AI) wa MauzoJuu. 
Jina lako ni "Mauzo" — mshauri hodari wa biashara.

KANUNI MUHIMU:
1. LAZIMA uzungumze Kiswahili DAIMA — hata kama mtumiaji anaandika kwa Kiingereza
2. Wewe ni mtaalamu wa biashara ndogo za Afrika Mashariki
3. Unaelewa vizuri bei za Tanzania, utamaduni wa biashara, na wateja wa Afrika Mashariki
4. Jibu kwa upole, kwa urafiki, lakini kwa uelewa mkubwa wa biashara
5. Toa ushauri wa vitendo — si tu nadharia
6. Jibu kwa ufupi na wazi — usiseme sana

MUKTADHA WA DUKA LA MTUMIAJI (Updated: Sasa hivi):
$muktadha

Unaweza:
- Kujibu maswali yoyote kuhusu biashara yake
- Kutoa ushauri wa bei, mauzo, na masoko
- Kutahadharisha kuhusu bidhaa zinazoisha
- Kupendekeza mbinu za kuongeza mauzo
- Kusaidia kujibu wateja (jinsi ya kuandika ujumbe wa wateja)
- Kuchunguza mwelekeo wa mauzo
- Kutoa ripoti fupi ya haraka'''
            }
          ]
        },
        {
          'role': 'model',
          'parts': [
            {
              'text':
                  'Niko hapa! Mimi ni Mauzo, msaidizi wako wa biashara. Niambie — unajihisi vipi leo? Na biashara inaendaje? 😊'
            }
          ]
        },
      ];

      // Ongeza historia ya mazungumzo
      for (final ujumbe in historia.length > 10 ? historia.sublist(historia.length - 10) : historia) {
        contents.add({
          'role': ujumbe.niAI ? 'model' : 'user',
          'parts': [
            {'text': ujumbe.maudhui}
          ]
        });
      }

      // Ongeza swali la sasa
      contents.add({
        'role': 'user',
        'parts': [
          {'text': swali}
        ]
      });

      final response = await http
          .post(
            Uri.parse(_geminiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': contents,
              'generationConfig': {
                'temperature': 0.8,
                'topK': 40,
                'topP': 0.95,
                'maxOutputTokens': 1024,
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jibu = data['candidates']?[0]?['content']?['parts']?[0]?['text']
            as String?;
        return jibu ?? 'Samahani, sikupata jibu. Jaribu tena.';
      } else {
        final error = jsonDecode(response.body);
        final errorMsg = error['error']?['message'] ?? 'Hitilafu isiyojulikana';
        return 'Samahani, kuna tatizo na AI: $errorMsg';
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return 'Samahani, AI ilichelewa kujibu. Angalia muunganiko wako wa mtandao na jaribu tena.';
      }
      return 'Hitilafu: $e';
    }
  }

  /// Pata ujumbe wa karibisho wa AI unaojua hali ya duka
  Future<String> ujumbeWaKaribisho() async {
    if (_geminiApiKey == 'WEKA_API_KEY_YAKO_HAPA') {
      return '👋 Karibu! Mimi ni Mauzo, msaidizi wako wa biashara wa AI.\n\n⚠️ Ili nifanye kazi, tafadhali weka Gemini API key yako kwenye `lib/services/ai_service.dart`.\n\nPata bure: https://aistudio.google.com/app/apikey';
    }

    try {
      final muktadha = await _pataMuktadha();

      final response = await http
          .post(
            Uri.parse(_geminiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'role': 'user',
                  'parts': [
                    {
                      'text': '''Wewe ni Mauzo, msaidizi wa AI wa biashara. Zungumza Kiswahili tu.
Toa ujumbe mfupi wa karibisho (si zaidi ya maneno 60) ukitumia data hii:

$muktadha

Anza na salamu ya joto, kisha toa muhtasari mfupi wa hali ya biashara leo (mauzo, maagizo yanayosubiri, na tahadhari moja muhimu kama ipo). Mwisho omba mtumiaji kukuambia ana swali gani.'''
                    }
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.9,
                'maxOutputTokens': 300,
              },
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String? ??
            '👋 Karibu! Mimi ni Mauzo, msaidizi wako wa biashara. Niambie unachohitaji!';
      }
    } catch (_) {}

    return '👋 Habari! Mimi ni Mauzo, msaidizi wako wa biashara. Niko hapa kukusaidia kuongeza mauzo na kusimamia duka lako. Niulize lolote! 😊';
  }
}
