import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/auth_service.dart';
import '../../services/bidhaa_service.dart';

class ProfailiScreen extends ConsumerStatefulWidget {
  const ProfailiScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfailiScreen> createState() => _ProfailiScreenState();
}

class _ProfailiScreenState extends ConsumerState<ProfailiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jinaCtrl = TextEditingController();
  final _simuCtrl = TextEditingController();

  bool _inahariri = false;
  bool _inahifadhi = false;
  File? _picha;

  @override
  void dispose() {
    _jinaCtrl.dispose();
    _simuCtrl.dispose();
    super.dispose();
  }

  Future<void> _chaguaPicha() async {
    final picker = ImagePicker();
    final picha = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 90,
    );
    if (picha != null) {
      setState(() => _picha = File(picha.path));
    }
  }

  Future<void> _hifadhiMabadiliko() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _inahifadhi = true);

    try {
      final Map<String, dynamic> data = {
        'jina': _jinaCtrl.text.trim(),
        'simu': _simuCtrl.text.trim(),
      };

      // Pakia picha mpya kama imechaguliwa
      if (_picha != null) {
        final uid = ref.read(authServiceProvider).mtumiaji?.uid ?? '';
        final storage = ref.read(bidhaaServiceProvider);
        final url = await storage.pakiaPicha(_picha!, 'profile_$uid');
        data['picha'] = url;
      }

      await ref.read(authServiceProvider).sasishaMtumiaji(data);

      if (mounted) {
        setState(() => _inahariri = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Profaili imesasishwa!',
                style: TextStyle(fontFamily: 'Poppins')),
            backgroundColor: const Color(0xFF00C853),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Hitilafu: $e',
                style: const TextStyle(fontFamily: 'Poppins')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _inahifadhi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mtumiajiAsync = ref.watch(mtumiajiStreamProvider);
    final dukaAsync = ref.watch(dukaStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        title: const Text('Profaili Yangu',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
        backgroundColor: const Color(0xFF0F1629),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_inahariri)
            TextButton.icon(
              onPressed: () {
                final mtumiaji = ref.read(mtumiajiStreamProvider).value;
                if (mtumiaji != null) {
                  _jinaCtrl.text = mtumiaji.jina;
                  _simuCtrl.text = mtumiaji.simu ?? '';
                }
                setState(() => _inahariri = true);
              },
              icon: const Icon(Icons.edit, color: Color(0xFF00E5FF), size: 18),
              label: const Text('Hariri',
                  style: TextStyle(color: Color(0xFF00E5FF), fontFamily: 'Poppins')),
            ),
        ],
      ),
      body: mtumiajiAsync.when(
        data: (mtumiaji) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00E5FF), Color(0xFF00C853)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: _picha != null
                          ? ClipOval(
                              child: Image.file(_picha!, fit: BoxFit.cover))
                          : mtumiaji?.picha != null
                              ? ClipOval(
                                  child: Image.network(mtumiaji!.picha!,
                                      fit: BoxFit.cover))
                              : Center(
                                  child: Text(
                                    mtumiaji != null && mtumiaji.jina.isNotEmpty
                                        ? mtumiaji.jina[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                        fontSize: 44,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                    ),
                    if (_inahariri)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _chaguaPicha,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF00C853),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                  ],
                ),
              ).animate().fadeIn().scale(),

              const SizedBox(height: 8),

              // Jina la duka
              dukaAsync.when(
                data: (duka) => Center(
                  child: Text(
                    '🏪 ${duka?.jina ?? ''}',
                    style: const TextStyle(
                        color: Color(0xFF00C853),
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),

              const SizedBox(height: 32),

              // Info Cards au Form
              if (!_inahariri) ...[
                _buildInfoCard(Icons.person, 'Jina Kamili', mtumiaji?.jina ?? '—'),
                const SizedBox(height: 12),
                _buildInfoCard(Icons.email, 'Barua Pepe', mtumiaji?.barua ?? '—'),
                const SizedBox(height: 12),
                _buildInfoCard(Icons.phone, 'Nambari ya Simu',
                    mtumiaji?.simu ?? 'Haijawekwa'),
                const SizedBox(height: 12),
                dukaAsync.when(
                  data: (duka) => _buildInfoCard(
                      Icons.store, 'Jina la Duka', duka?.jina ?? '—'),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ] else ...[
                // Edit Form
                _buildEditField('Jina Kamili', _jinaCtrl, Icons.person),
                const SizedBox(height: 16),
                _buildEditField('Nambari ya Simu', _simuCtrl, Icons.phone,
                    isPhone: true),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            setState(() => _inahariri = false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Ghairi',
                            style: TextStyle(
                                color: Colors.white54,
                                fontFamily: 'Poppins')),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _inahifadhi ? null : _hifadhiMabadiliko,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C853),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _inahifadhi
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Hifadhi Mabadiliko',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF00C853))),
        error: (e, _) => Center(
            child: Text('Hitilafu: $e',
                style: const TextStyle(color: Colors.red, fontFamily: 'Poppins'))),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1629),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2D50), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF00E5FF), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white54,
                        fontFamily: 'Poppins',
                        fontSize: 12)),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildEditField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    bool isPhone = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Colors.white54, fontFamily: 'Poppins'),
        prefixIcon: Icon(icon, color: const Color(0xFF00E5FF)),
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
      validator: (v) =>
          v == null || v.isEmpty ? 'Tafadhali jaza hapa' : null,
    ).animate().fadeIn().slideX();
  }
}
