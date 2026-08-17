import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../services/duka_service.dart';
import '../../models/mtumiaji.dart';

class DukaScreen extends ConsumerStatefulWidget {
  const DukaScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DukaScreen> createState() => _DukaScreenState();
}

class _DukaScreenState extends ConsumerState<DukaScreen> {
  final _formKey = GlobalKey<FormState>();

  final _jinaCtrl = TextEditingController();
  final _maelezoCtrl = TextEditingController();
  final _anwaaniCtrl = TextEditingController();
  final _simuCtrl = TextEditingController();
  final _baruaCtrl = TextEditingController();

  Color _rangiKuu = const Color(0xFF00C853);
  bool _imefunguliwa = true;
  bool _inahifadhi = false;
  bool _imejazwa = false; // Guard dhidi ya kujaza controllers mara nyingi

  File? _logoMpya;
  File? _bannerMpya;

  static const _rangiZote = [
    Color(0xFF00C853),
    Color(0xFF00E5FF),
    Color(0xFFFFC107),
    Colors.purpleAccent,
    Colors.redAccent,
    Color(0xFFFF6D00),
  ];

  @override
  void dispose() {
    _jinaCtrl.dispose();
    _maelezoCtrl.dispose();
    _anwaaniCtrl.dispose();
    _simuCtrl.dispose();
    _baruaCtrl.dispose();
    super.dispose();
  }

  void _jazaControllers(DukaModel duka) {
    if (_imejazwa) return;
    _imejazwa = true;
    _jinaCtrl.text = duka.jina;
    _maelezoCtrl.text = duka.maelezo ?? '';
    _anwaaniCtrl.text = duka.anwani ?? '';
    _simuCtrl.text = duka.simu ?? '';
    _baruaCtrl.text = duka.barua ?? '';
    _imefunguliwa = duka.imefunguliwa;
    // Parse rangi kutoka hex string
    try {
      final hex = duka.rangiKuu.replaceAll('#', '');
      final colorVal = int.parse('FF$hex', radix: 16);
      setState(() => _rangiKuu = Color(colorVal));
    } catch (_) {}
  }

  Future<void> _chaguaPicha(bool niLogo) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    setState(() {
      if (niLogo) {
        _logoMpya = File(file.path);
      } else {
        _bannerMpya = File(file.path);
      }
    });
  }

  Future<void> _hifadhi(DukaModel duka) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _inahifadhi = true);

    try {
      final service = ref.read(dukaServiceProvider);

      // Pakia picha mpya kama zipo
      if (_logoMpya != null) {
        await service.pakiaLogo(_logoMpya!, duka.id);
      }
      if (_bannerMpya != null) {
        await service.pakiaBanner(_bannerMpya!, duka.id);
      }

      // Badilisha rangi kuwa hex string
      final hex =
          '#${_rangiKuu.r.toInt().toRadixString(16).padLeft(2, '0')}${_rangiKuu.g.toInt().toRadixString(16).padLeft(2, '0')}${_rangiKuu.b.toInt().toRadixString(16).padLeft(2, '0')}';

      await service.sasishaDuka(dukaId: duka.id, data: {
        'jina': _jinaCtrl.text.trim(),
        'maelezo': _maelezoCtrl.text.trim(),
        'anwani': _anwaaniCtrl.text.trim(),
        'simu': _simuCtrl.text.trim(),
        'barua': _baruaCtrl.text.trim(),
        'rangiKuu': hex,
        'imefunguliwa': _imefunguliwa,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Duka limehifadhiwa!', style: TextStyle(fontFamily: 'Poppins')),
            ]),
            backgroundColor: const Color(0xFF00C853),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hitilafu: $e', style: const TextStyle(fontFamily: 'Poppins')),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _inahifadhi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dukaAsync = ref.watch(myDukaProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        title: const Text('Duka Langu',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F1629),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: dukaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00C853))),
        error: (err, _) => Center(
          child: Text('Hitilafu: $err', style: const TextStyle(color: Colors.red, fontFamily: 'Poppins')),
        ),
        data: (duka) {
          if (duka == null) {
            return const Center(
              child: Text('Duka halipatikani', style: TextStyle(color: Colors.white54, fontFamily: 'Poppins')),
            );
          }
          _jazaControllers(duka);
          return _buildForm(duka);
        },
      ),
    );
  }

  Widget _buildForm(DukaModel duka) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ── Banner ──────────────────────────────────────────────
            _buildBanner(duka).animate().fadeIn(),

            const SizedBox(height: 60),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Status Badge ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (_imefunguliwa
                                  ? const Color(0xFF00C853)
                                  : Colors.redAccent)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (_imefunguliwa
                                    ? const Color(0xFF00C853)
                                    : Colors.redAccent)
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          _imefunguliwa ? '🟢 Duka Limefunguliwa' : '🔴 Duka Limefungwa',
                          style: TextStyle(
                            color: _imefunguliwa ? const Color(0xFF00C853) : Colors.redAccent,
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Switch(
                        value: _imefunguliwa,
                        onChanged: (val) => setState(() => _imefunguliwa = val),
                        activeThumbColor: _rangiKuu,
                        activeTrackColor: _rangiKuu.withValues(alpha: 0.3),
                      ),
                    ],
                  ).animate().fadeIn().slideY(),

                  const SizedBox(height: 24),

                  // ── Jina la Duka ─────────────────────────────────
                  _buildLabel('🏪 Jina la Duka *'),
                  _buildTextField(_jinaCtrl, 'Mfano: MauzoJuu Store',
                      validator: (v) => v == null || v.isEmpty ? 'Jaza jina la duka' : null),
                  const SizedBox(height: 16),

                  // ── Maelezo ──────────────────────────────────────
                  _buildLabel('📝 Maelezo ya Duka'),
                  _buildTextField(_maelezoCtrl, 'Elezea bidhaa unazouza...', maxLines: 3),
                  const SizedBox(height: 16),

                  // ── Anwani ───────────────────────────────────────
                  _buildLabel('📍 Anwani'),
                  _buildTextField(_anwaaniCtrl, 'Mfano: Dar es Salaam, Kinondoni'),
                  const SizedBox(height: 16),

                  // ── Simu ─────────────────────────────────────────
                  _buildLabel('📱 Simu'),
                  _buildTextField(_simuCtrl, 'Mfano: 0712 345 678',
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),

                  // ── Barua Pepe ───────────────────────────────────
                  _buildLabel('✉️ Barua Pepe'),
                  _buildTextField(_baruaCtrl, 'duka@example.com',
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 24),

                  // ── Rangi Kuu ────────────────────────────────────
                  _buildLabel('🎨 Rangi Kuu ya Duka'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _rangiZote.map((c) {
                      final imechaguliwa = _rangiKuu == c;
                      return GestureDetector(
                        onTap: () => setState(() => _rangiKuu = c),
                        child: AnimatedContainer(
                          duration: 200.ms,
                          width: imechaguliwa ? 52 : 44,
                          height: imechaguliwa ? 52 : 44,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: imechaguliwa ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: imechaguliwa
                                ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 2)]
                                : null,
                          ),
                          child: imechaguliwa
                              ? const Icon(Icons.check, color: Colors.white, size: 22)
                              : null,
                        ),
                      );
                    }).toList(),
                  ).animate().fadeIn().slideX(),

                  const SizedBox(height: 40),

                  // ── Kitufe cha Hifadhi ───────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _inahifadhi ? null : () => _hifadhi(duka),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _rangiKuu,
                        disabledBackgroundColor: _rangiKuu.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                        shadowColor: _rangiKuu.withValues(alpha: 0.4),
                      ),
                      child: _inahifadhi
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save_rounded, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Hifadhi Mabadiliko',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ],
                            ),
                    ),
                  ).animate().scale(delay: 100.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(DukaModel duka) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Banner
        GestureDetector(
          onTap: () => _chaguaPicha(false),
          child: Stack(
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _rangiKuu.withValues(alpha: 0.15),
                ),
                child: _bannerMpya != null
                    ? Image.file(_bannerMpya!, fit: BoxFit.cover)
                    : (duka.banner != null && duka.banner!.isNotEmpty)
                        ? CachedNetworkImage(imageUrl: duka.banner!, fit: BoxFit.cover)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_rounded,
                                  color: _rangiKuu.withValues(alpha: 0.6), size: 40),
                              const SizedBox(height: 8),
                              Text('Bonyeza kupakia picha ya banner',
                                  style: TextStyle(
                                    color: _rangiKuu.withValues(alpha: 0.8),
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                  )),
                            ],
                          ),
              ),
              // Edit overlay
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),

        // Logo
        Positioned(
          bottom: -44,
          child: GestureDetector(
            onTap: () => _chaguaPicha(true),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF070B14), width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: _rangiKuu.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: _rangiKuu.withValues(alpha: 0.2),
                    backgroundImage: _logoMpya != null
                        ? FileImage(_logoMpya!) as ImageProvider
                        : (duka.logo != null && duka.logo!.isNotEmpty)
                            ? CachedNetworkImageProvider(duka.logo!) as ImageProvider
                            : null,
                    child: (_logoMpya == null && (duka.logo == null || duka.logo!.isEmpty))
                        ? Icon(Icons.store_rounded, color: _rangiKuu, size: 36)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _rangiKuu,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF070B14), width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontFamily: 'Poppins', fontSize: 14),
        filled: true,
        fillColor: const Color(0xFF0F1629),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _rangiKuu, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }
}
