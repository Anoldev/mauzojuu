import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/bidhaa.dart';
import '../../services/bidhaa_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

// Provider ya bidhaa moja (real-time)
final bidhaaDetailProvider =
    StreamProvider.family<BidhaaModel?, String>((ref, id) {
  return FirebaseFirestore.instance
      .collection(AppConstants.bidhaaCollection)
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? BidhaaModel.fromFirestore(doc) : null);
});

class BidhaaDetailScreen extends ConsumerStatefulWidget {
  final String bidhaaId;
  const BidhaaDetailScreen({Key? key, required this.bidhaaId}) : super(key: key);

  @override
  ConsumerState<BidhaaDetailScreen> createState() => _BidhaaDetailScreenState();
}

class _BidhaaDetailScreenState extends ConsumerState<BidhaaDetailScreen> {
  int _currentImage = 0;

  Future<void> _futaBidhaa(BidhaaModel bidhaa) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1629),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Futa Bidhaa', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        content: Text(
          'Una uhakika wa kufuta "${bidhaa.jina}"? Kitendo hiki hakiwezi kurudishwa.',
          style: const TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hapana', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Futa', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      // Futa picha kwanza
      final service = ref.read(bidhaaServiceProvider);
      for (final url in bidhaa.picha) {
        await service.futaPicha(url);
      }
      await service.futaBidhaa(bidhaa.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Bidhaa imefutwa!', style: TextStyle(fontFamily: 'Poppins')),
            ]),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hitilafu: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _harisBidhaa(BidhaaModel bidhaa) {
    _showEditDialog(bidhaa);
  }

  Future<void> _showEditDialog(BidhaaModel bidhaa) async {
    final jinaCtrl = TextEditingController(text: bidhaa.jina);
    final beiCtrl = TextEditingController(text: bidhaa.bei.toStringAsFixed(0));
    final idadiCtrl = TextEditingController(text: bidhaa.idadi.toString());
    final maelezoCtrl = TextEditingController(text: bidhaa.maelezo);
    bool inapatikana = bidhaa.inapatikana;
    bool inasasisha = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F1629),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('✏️ Hariri Bidhaa',
                  style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              _buildEditField(jinaCtrl, 'Jina la Bidhaa'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildEditField(beiCtrl, 'Bei (TZS)', isNumber: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildEditField(idadiCtrl, 'Stock', isNumber: true)),
                ],
              ),
              const SizedBox(height: 12),
              _buildEditField(maelezoCtrl, 'Maelezo', maxLines: 3),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bidhaa Inapatikana', style: TextStyle(color: Colors.white70, fontFamily: 'Poppins')),
                  Switch(
                    value: inapatikana,
                    onChanged: (val) => setModalState(() => inapatikana = val),
                    activeThumbColor: const Color(0xFF00C853),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: inasasisha
                      ? null
                      : () async {
                          setModalState(() => inasasisha = true);
                          try {
                            await ref.read(bidhaaServiceProvider).sasakishaBidhaa(bidhaa.id, {
                              'jina': jinaCtrl.text.trim(),
                              'bei': double.tryParse(beiCtrl.text) ?? bidhaa.bei,
                              'idadi': int.tryParse(idadiCtrl.text) ?? bidhaa.idadi,
                              'maelezo': maelezoCtrl.text.trim(),
                              'inapatikana': inapatikana,
                            });
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(children: [
                                    Icon(Icons.check_circle, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Bidhaa imesasishwa!', style: TextStyle(fontFamily: 'Poppins')),
                                  ]),
                                  backgroundColor: const Color(0xFF00C853),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          } catch (e) {
                            setModalState(() => inasasisha = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: inasasisha
                      ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                      : const Text('Hifadhi',
                          style: TextStyle(color: Colors.black, fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    jinaCtrl.dispose();
    beiCtrl.dispose();
    idadiCtrl.dispose();
    maelezoCtrl.dispose();
  }

  Widget _buildEditField(TextEditingController ctrl, String label, {int maxLines = 1, bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontFamily: 'Poppins'),
        filled: true,
        fillColor: const Color(0xFF1A2035),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFC107), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bidhaaAsync = ref.watch(bidhaaDetailProvider(widget.bidhaaId));

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: bidhaaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00C853))),
        error: (err, _) => Center(child: Text('Hitilafu: $err', style: const TextStyle(color: Colors.red))),
        data: (bidhaa) {
          if (bidhaa == null) {
            return const Center(child: Text('Bidhaa haipatikani', style: TextStyle(color: Colors.white54)));
          }
          return _buildBody(bidhaa);
        },
      ),
    );
  }

  Widget _buildBody(BidhaaModel bidhaa) {
    return CustomScrollView(
      slivers: [
        // ── App Bar na Picha ────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: const Color(0xFF0F1629),
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                bidhaa.picha.isNotEmpty
                    ? PageView.builder(
                        itemCount: bidhaa.picha.length,
                        onPageChanged: (i) => setState(() => _currentImage = i),
                        itemBuilder: (_, i) => CachedNetworkImage(
                          imageUrl: bidhaa.picha[i],
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: const Color(0xFF0F1629),
                              child: const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)))),
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFF0F1629),
                            child: const Icon(Icons.image, size: 80, color: Colors.white24),
                          ),
                        ),
                      )
                    : Container(
                        color: const Color(0xFF0F1629),
                        child: const Icon(Icons.inventory_2_outlined, size: 100, color: Colors.white24),
                      ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, const Color(0xFF070B14).withValues(alpha: 0.8)],
                    ),
                  ),
                ),
                // Dots
                if (bidhaa.picha.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0, right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(bidhaa.picha.length, (i) => AnimatedContainer(
                        duration: 200.ms,
                        width: i == _currentImage ? 20 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: i == _currentImage ? const Color(0xFF00C853) : Colors.white38,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )),
                    ),
                  ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Jina na Kategoria ──────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(bidhaa.jina,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 22, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
                    ),
                    child: Text(bidhaa.kategoria,
                        style: const TextStyle(color: Color(0xFF00E5FF), fontFamily: 'Poppins', fontSize: 12)),
                  ),
                ],
              ).animate().fadeIn().slideX(),

              const SizedBox(height: 8),

              // ── Bei ────────────────────────────────────────────────
              Row(
                children: [
                  Text(AppHelpers.formatBei(bidhaa.bei),
                      style: const TextStyle(
                          color: Color(0xFF00C853), fontSize: 24, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                  if (bidhaa.inaPunguzo) ...[
                    const SizedBox(width: 12),
                    Text(AppHelpers.formatBei(bidhaa.beiAsili!),
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 14, fontFamily: 'Poppins',
                            decoration: TextDecoration.lineThrough)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${bidhaa.asilimiaYaPunguzo.toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.redAccent, fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ).animate().fadeIn().slideX(),

              const SizedBox(height: 20),

              // ── Stats ──────────────────────────────────────────────
              Row(
                children: [
                  _buildStatCard('📦', 'Stock', bidhaa.idadi.toString(), const Color(0xFF00E5FF)),
                  const SizedBox(width: 12),
                  _buildStatCard('📈', 'Mauzo', bidhaa.mauzo.toString(), const Color(0xFF00C853)),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    bidhaa.inapatikana ? '✅' : '❌',
                    'Hali',
                    bidhaa.inapatikana ? 'Inapatikana' : 'Haipatikani',
                    bidhaa.inapatikana ? const Color(0xFF00C853) : Colors.redAccent,
                  ),
                ],
              ).animate().fadeIn(delay: 50.ms).slideY(),

              const SizedBox(height: 20),

              // ── Maelezo ────────────────────────────────────────────
              if (bidhaa.maelezo.isNotEmpty) ...[
                const Text('📝 Maelezo',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(bidhaa.maelezo,
                    style: const TextStyle(color: Colors.white70, fontFamily: 'Poppins', height: 1.6)),
                const SizedBox(height: 20),
              ],

              // ── Tarehe ─────────────────────────────────────────────
              Text(
                'Iliongezwa: ${AppHelpers.formatTarehe(bidhaa.iliyoundwa)}',
                style: const TextStyle(color: Colors.white38, fontFamily: 'Poppins', fontSize: 12),
              ),

              const SizedBox(height: 32),

              // ── Vitendo ────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _harisBidhaa(bidhaa),
                      icon: const Icon(Icons.edit_rounded, color: Colors.black, size: 18),
                      label: const Text('Hariri',
                          style: TextStyle(color: Colors.black, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 6,
                        shadowColor: const Color(0xFFFFC107).withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _futaBidhaa(bidhaa),
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 18),
                      label: const Text('Futa',
                          style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 6,
                        shadowColor: Colors.redAccent.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms).slideY(),

              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(color: color, fontSize: 14, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(label, style: const TextStyle(color: Colors.white38, fontFamily: 'Poppins', fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
