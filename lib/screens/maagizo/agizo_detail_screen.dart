import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/agizo.dart';
import '../../services/agizo_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

// Provider ya agizo moja
final agizoDetailProvider =
    StreamProvider.family<AgizoModel?, String>((ref, id) {
  return FirebaseFirestore.instance
      .collection(AppConstants.maagizaCollection)
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? AgizoModel.fromFirestore(doc) : null);
});

class AgizoDetailScreen extends ConsumerStatefulWidget {
  final String agizoId;
  const AgizoDetailScreen({Key? key, required this.agizoId}) : super(key: key);

  @override
  ConsumerState<AgizoDetailScreen> createState() => _AgizoDetailScreenState();
}

class _AgizoDetailScreenState extends ConsumerState<AgizoDetailScreen> {
  String? _haliMpya;
  bool _inasasisha = false;

  Future<void> _sasishaHali(AgizoModel agizo) async {
    if (_haliMpya == null || _haliMpya == agizo.hali) return;
    setState(() => _inasasisha = true);
    try {
      await ref.read(agizoServiceProvider).sasakishaHali(agizo.id, _haliMpya!);
      if (mounted) {
        final haliInfo = AppHelpers.getHaliAgizo(_haliMpya!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              Text(haliInfo['icon'] as String, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Hali imesasishwa: ${haliInfo['jina']}',
                  style: const TextStyle(fontFamily: 'Poppins')),
            ]),
            backgroundColor: Color(haliInfo['rangi'] as int),
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
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _inasasisha = false);
    }
  }

  Future<void> _futaAgizo(AgizoModel agizo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1629),
        title: const Text('Futa Agizo', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        content: const Text('Una uhakika wa kufuta agizo hili? Kitendo hiki hakiwezi kurudishwa.',
            style: TextStyle(color: Colors.white70, fontFamily: 'Poppins')),
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
      await ref.read(agizoServiceProvider).futaAgizo(agizo.id);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hitilafu: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final agizoAsync = ref.watch(agizoDetailProvider(widget.agizoId));

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        title: Text(
          'Agizo #${widget.agizoId.substring(0, 6).toUpperCase()}',
          style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0F1629),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          agizoAsync.when(
            data: (agizo) => agizo != null
                ? IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => _futaAgizo(agizo),
                    tooltip: 'Futa Agizo',
                  )
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: agizoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00C853))),
        error: (err, _) => Center(
          child: Text('Hitilafu: $err', style: const TextStyle(color: Colors.red, fontFamily: 'Poppins')),
        ),
        data: (agizo) {
          if (agizo == null) {
            return const Center(
              child: Text('Agizo halipatikani', style: TextStyle(color: Colors.white54, fontFamily: 'Poppins')),
            );
          }
          _haliMpya ??= agizo.hali;
          return _buildBody(agizo);
        },
      ),
    );
  }

  Widget _buildBody(AgizoModel agizo) {
    final haliInfo = AppHelpers.getHaliAgizo(agizo.hali);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hali ya Sasa ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(haliInfo['rangi'] as int).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(haliInfo['rangi'] as int).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Text(haliInfo['icon'] as String, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hali ya Agizo', style: TextStyle(color: Colors.white54, fontFamily: 'Poppins', fontSize: 12)),
                    Text(haliInfo['jina'] as String,
                        style: TextStyle(
                            color: Color(haliInfo['rangi'] as int),
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const Spacer(),
                Text(AppHelpers.formatTarehe(agizo.iliyoundwa),
                    style: const TextStyle(color: Colors.white38, fontFamily: 'Poppins', fontSize: 11)),
              ],
            ),
          ).animate().fadeIn().slideY(),

          const SizedBox(height: 20),

          // ── Taarifa za Mteja ─────────────────────────────────────
          _buildSectionHeader('👤 Taarifa za Mteja', Icons.person_outline),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1629),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                _buildInfoRow('Jina', agizo.mtejaMjina),
                const Divider(color: Colors.white10, height: 20),
                _buildInfoRow('Simu', agizo.mtejaSimu),
                const Divider(color: Colors.white10, height: 20),
                _buildInfoRow('Anwani', agizo.mtejaAnwani),
                if (agizo.maelezo != null && agizo.maelezo!.isNotEmpty) ...[
                  const Divider(color: Colors.white10, height: 20),
                  _buildInfoRow('Maelezo', agizo.maelezo!),
                ],
              ],
            ),
          ).animate().fadeIn(delay: 50.ms).slideY(),

          const SizedBox(height: 20),

          // ── Bidhaa Zilizoagizwa ──────────────────────────────────
          _buildSectionHeader('🛍️ Bidhaa Zilizoagizwa (${agizo.bidhaa.length})', Icons.shopping_bag_outlined),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F1629),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: agizo.bidhaa.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
              itemBuilder: (context, i) {
                final item = agizo.bidhaa[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2035),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: item.bidhaapicha != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: item.bidhaapicha!,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => const Icon(Icons.image, color: Colors.white38),
                            ),
                          )
                        : const Icon(Icons.inventory_2_outlined, color: Colors.white38),
                  ),
                  title: Text(item.bidhaaJina,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                  subtitle: Text('${item.idadi} x ${AppHelpers.formatBei(item.bei)}',
                      style: const TextStyle(color: Colors.white54, fontFamily: 'Poppins', fontSize: 12)),
                  trailing: Text(AppHelpers.formatBei(item.jumla),
                      style: const TextStyle(color: Color(0xFF00C853), fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                );
              },
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(),

          const SizedBox(height: 20),

          // ── Jumla ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00C853).withValues(alpha: 0.15),
                  const Color(0xFF0F1629),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00C853).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('💰 Jumla ya Malipo',
                    style: TextStyle(color: Colors.white70, fontFamily: 'Poppins', fontSize: 15)),
                Text(AppHelpers.formatBei(agizo.jumla),
                    style: const TextStyle(
                        color: Color(0xFF00C853),
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ).animate().fadeIn(delay: 150.ms).slideY(),

          const SizedBox(height: 24),

          // ── Sasisha Hali ─────────────────────────────────────────
          _buildSectionHeader('🔄 Sasisha Hali ya Agizo', Icons.update),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1629),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                AppConstants.orderPending,
                AppConstants.orderProcessing,
                AppConstants.orderShipped,
                AppConstants.orderDelivered,
                AppConstants.orderCancelled,
              ].map((hali) {
                final info = AppHelpers.getHaliAgizo(hali);
                final imechaguliwa = _haliMpya == hali;
                final rangi = Color(info['rangi'] as int);
                return InkWell(
                  onTap: () => setState(() => _haliMpya = hali),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: hali,
                          groupValue: _haliMpya, // ignore: deprecated_member_use
                          onChanged: (val) => setState(() => _haliMpya = val), // ignore: deprecated_member_use
                          activeColor: rangi,
                        ),
                        Text(info['icon'] as String),
                        const SizedBox(width: 8),
                        Text(info['jina'] as String,
                            style: TextStyle(
                              color: imechaguliwa ? rangi : Colors.white70,
                              fontFamily: 'Poppins',
                              fontWeight: imechaguliwa ? FontWeight.bold : FontWeight.normal,
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(),

          const SizedBox(height: 24),

          // ── Kitufe cha Sasisha ───────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (_inasasisha || _haliMpya == agizo.hali)
                  ? null
                  : () => _sasishaHali(agizo),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                disabledBackgroundColor: Colors.white12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                shadowColor: const Color(0xFF00E5FF).withValues(alpha: 0.3),
              ),
              child: _inasasisha
                  ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.update_rounded, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Sasisha Hali',
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
            ),
          ).animate().scale(delay: 250.ms),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFC107), size: 18),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(color: Colors.white38, fontFamily: 'Poppins', fontSize: 13)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
