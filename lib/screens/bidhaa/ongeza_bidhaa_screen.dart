import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/bidhaa.dart';
import '../../services/bidhaa_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class OngezaBidhaaScreen extends ConsumerStatefulWidget {
  const OngezaBidhaaScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OngezaBidhaaScreen> createState() =>
      _OngezaBidhaaScreenState();
}

class _OngezaBidhaaScreenState extends ConsumerState<OngezaBidhaaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _jinaCtrl = TextEditingController();
  final _beiCtrl = TextEditingController();
  final _beiAsiliCtrl = TextEditingController();
  final _idadiCtrl = TextEditingController();
  final _maelezoCtrl = TextEditingController();

  String? _kategoria;
  bool _inapatikana = true;
  bool _inahifadhi = false;
  List<File> _pichaZilizochaguliwa = [];

  @override
  void dispose() {
    _jinaCtrl.dispose();
    _beiCtrl.dispose();
    _beiAsiliCtrl.dispose();
    _idadiCtrl.dispose();
    _maelezoCtrl.dispose();
    super.dispose();
  }

  Future<void> _chaguaPicha() async {
    if (_pichaZilizochaguliwa.length >= 5) return;
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF0F1629),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('Chagua Picha',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF00E5FF)),
              title: const Text('Camera',
                  style:
                      TextStyle(color: Colors.white, fontFamily: 'Poppins')),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF00C853)),
              title: const Text('Picha za Simu',
                  style:
                      TextStyle(color: Colors.white, fontFamily: 'Poppins')),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picha = await picker.pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picha != null) {
      setState(() => _pichaZilizochaguliwa.add(File(picha.path)));
    }
  }

  Future<void> _hifadhiBidhaa() async {
    if (!_formKey.currentState!.validate()) return;

    final mtumiaji = ref.read(authServiceProvider).mtumiaji;
    if (mtumiaji == null) return;

    setState(() => _inahifadhi = true);

    try {
      final service = ref.read(bidhaaServiceProvider);
      final bidhaaId =
          DateTime.now().millisecondsSinceEpoch.toString();

      // Pakia picha kwenye Firebase Storage
      List<String> picha = [];
      for (final f in _pichaZilizochaguliwa) {
        final url = await service.pakiaPicha(f, bidhaaId);
        picha.add(url);
      }

      final bidhaa = BidhaaModel(
        id: '',
        dukaId: mtumiaji.uid,
        jina: _jinaCtrl.text.trim(),
        maelezo: _maelezoCtrl.text.trim(),
        bei: double.parse(_beiCtrl.text.trim()),
        beiAsili:
            _beiAsiliCtrl.text.isNotEmpty ? double.parse(_beiAsiliCtrl.text.trim()) : null,
        picha: picha,
        idadi: int.parse(_idadiCtrl.text.trim()),
        kategoria: _kategoria ?? 'Nyingine',
        inapatikana: _inapatikana,
        iliyoundwa: DateTime.now(),
        iliyosasishwa: DateTime.now(),
      );

      await service.ongezaBidhaa(bidhaa);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Bidhaa imehifadhiwa!',
                style: TextStyle(fontFamily: 'Poppins')),
            backgroundColor: const Color(0xFF00C853),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Hitilafu: $e',
                style: const TextStyle(fontFamily: 'Poppins')),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _inahifadhi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        title: const Text('Bidhaa Mpya',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
        backgroundColor: const Color(0xFF0F1629),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Picker Section
            const Text('Picha za Bidhaa (Max 5)',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Add button
                  if (_pichaZilizochaguliwa.length < 5)
                    GestureDetector(
                      onTap: _chaguaPicha,
                      child: Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1629),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                              width: 1.5,
                              style: BorderStyle.solid),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: Color(0xFF00E5FF), size: 28),
                            SizedBox(height: 4),
                            Text('Ongeza',
                                style: TextStyle(
                                    color: Color(0xFF00E5FF),
                                    fontFamily: 'Poppins',
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                    ).animate().scale(),
                  // Picked images
                  ..._pichaZilizochaguliwa.asMap().entries.map((entry) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(entry.value),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => setState(
                                () => _pichaZilizochaguliwa.removeAt(entry.key)),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn().scale();
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Form Fields
            _buildTextField('Jina la Bidhaa *', _jinaCtrl),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Bei (TZS) *', _beiCtrl, isNumber: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Bei ya Awali', _beiAsiliCtrl, isNumber: true, required: false)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField('Idadi Iliyopo (Stock) *', _idadiCtrl, isNumber: true),
            const SizedBox(height: 16),
            _buildTextField('Maelezo ya Bidhaa', _maelezoCtrl,
                maxLines: 4, required: false),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Kategoria *',
                labelStyle:
                    const TextStyle(color: Colors.white54, fontFamily: 'Poppins'),
                filled: true,
                fillColor: const Color(0xFF0F1629),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              dropdownColor: const Color(0xFF0F1629),
              style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              initialValue: _kategoria,
              hint: const Text('Chagua kategoria',
                  style: TextStyle(color: Colors.white54, fontFamily: 'Poppins')),
              items: AppConstants.categories
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _kategoria = val),
              validator: (val) => val == null ? 'Chagua kategoria' : null,
            ).animate().fadeIn().slideX(),

            const SizedBox(height: 16),

            // Availability Switch
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1629),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bidhaa Inapatikana',
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'Poppins')),
                      Text('Wateja wataiona dukani',
                          style: TextStyle(
                              color: Colors.white54,
                              fontFamily: 'Poppins',
                              fontSize: 12)),
                    ],
                  ),
                  Switch(
                    value: _inapatikana,
                    onChanged: (val) => setState(() => _inapatikana = val),
                    activeThumbColor: const Color(0xFF00C853),
                  ),
                ],
              ),
            ).animate().fadeIn().slideX(),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _inahifadhi ? null : _hifadhiBidhaa,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  disabledBackgroundColor: const Color(0xFF00C853).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _inahifadhi
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)),
                          SizedBox(width: 12),
                          Text('Inahifadhi...',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ],
                      )
                    : const Text('💾 Hifadhi Bidhaa',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
              ).animate().scale(),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    bool isNumber = false,
    int maxLines = 1,
    bool required = true,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.multiline,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Colors.white54, fontFamily: 'Poppins'),
        filled: true,
        fillColor: const Color(0xFF0F1629),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF00E5FF), width: 1.5)),
      ),
      validator: required
          ? (value) =>
              value == null || value.isEmpty ? 'Tafadhali jaza hapa' : null
          : null,
    ).animate().fadeIn().slideX();
  }
}
