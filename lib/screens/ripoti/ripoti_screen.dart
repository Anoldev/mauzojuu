import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/bidhaa.dart';
import '../../models/agizo.dart';
import '../../services/agizo_service.dart';
import '../../services/bidhaa_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

// Provider ya data ya chati ya siku 7
final mauzoSiku7Provider = StreamProvider<List<FlSpot>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();

  final sasa = DateTime.now();
  final wiki = sasa.subtract(const Duration(days: 6));
  final mwanzoWaWiki = DateTime(wiki.year, wiki.month, wiki.day);

  return FirebaseFirestore.instance
      .collection(AppConstants.maagizaCollection)
      .where('dukaId', isEqualTo: uid)
      .where('hali', isEqualTo: AppConstants.orderDelivered)
      .snapshots()
      .map((snap) {
    // Hesabu mauzo kwa kila siku ya wiki
    final Map<int, double> mauzoKwaSiku = {};
    for (int i = 0; i < 7; i++) {
      mauzoKwaSiku[i] = 0;
    }

    for (final doc in snap.docs) {
      final agizo = AgizoModel.fromFirestore(doc);
      final tarehe = agizo.iliyoundwa;
      if (tarehe.isAfter(mwanzoWaWiki) || tarehe.isAtSameMomentAs(mwanzoWaWiki)) {
        final siku = sasa.difference(tarehe).inDays;
        if (siku >= 0 && siku < 7) {
          mauzoKwaSiku[6 - siku] = (mauzoKwaSiku[6 - siku] ?? 0) + agizo.jumla;
        }
      }
    }

    return List.generate(
        7, (i) => FlSpot(i.toDouble(), (mauzoKwaSiku[i] ?? 0) / 1000)); // Kwa elfu
  });
});

// Provider ya bidhaa 5 bora
final bidhaa5BoraNzuri = StreamProvider<List<BidhaaModel>>((ref) {
  return ref.watch(bidhaaListProvider).when(
    data: (bidhaa) {
      final sorted = [...bidhaa]..sort((a, b) => b.mauzo.compareTo(a.mauzo));
      return Stream.value(sorted.take(5).toList());
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

class RipotiScreen extends ConsumerWidget {
  const RipotiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(maagizoStatsProvider);
    final chatiAsync = ref.watch(mauzoSiku7Provider);
    final bidhaaAsync = ref.watch(bidhaa5BoraNzuri);

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        title: const Text('Ripoti & Takwimu',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F1629),
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: const Color(0xFF00C853),
        backgroundColor: const Color(0xFF0F1629),
        onRefresh: () async {
          // Riverpod providers zinasasishwa kiotomatiki, refresh UI tu
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Summary Cards ──────────────────────────────────────
              statsAsync.when(
                loading: () => _buildLoadingCards(),
                error: (_, __) => const SizedBox(),
                data: (stats) => Column(
                  children: [
                    Row(
                      children: [
                        _buildSummaryCard(
                          'Mauzo Leo',
                          AppHelpers.formatBei(stats['mauzoLeo'] as double),
                          Icons.today_rounded,
                          const Color(0xFF00C853),
                        ),
                        const SizedBox(width: 12),
                        _buildSummaryCard(
                          'Mauzo Mwezi',
                          AppHelpers.formatBei(stats['mauzoMwezi'] as double),
                          Icons.calendar_month_rounded,
                          const Color(0xFF00E5FF),
                        ),
                      ],
                    ).animate().fadeIn().slideY(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildSummaryCard(
                          'Maagizo Yote',
                          '${stats['maagizaYote']}',
                          Icons.shopping_cart_rounded,
                          const Color(0xFFFFC107),
                        ),
                        const SizedBox(width: 12),
                        _buildSummaryCard(
                          'Yanayosubiri',
                          '${stats['yanayosubiri']}',
                          Icons.pending_actions_rounded,
                          Colors.purpleAccent,
                        ),
                      ],
                    ).animate().fadeIn(delay: 100.ms).slideY(),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Chati ya Siku 7 ────────────────────────────────────
              const Text('📈 Mwelekeo wa Mauzo (Siku 7)',
                  style: TextStyle(
                      color: Colors.white, fontFamily: 'Poppins', fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Mauzo yaliyokamilika kwa elfu (TZS K)',
                  style: TextStyle(color: Colors.white38, fontFamily: 'Poppins', fontSize: 12)),
              const SizedBox(height: 16),

              Container(
                height: 220,
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1629),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: chatiAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00C853))),
                  error: (_, __) => const Center(child: Text('Hitilafu', style: TextStyle(color: Colors.red))),
                  data: (spots) {
                    final sasa = DateTime.now();
                    final majina = List.generate(7, (i) {
                      final d = sasa.subtract(Duration(days: 6 - i));
                      return ['J', 'T', 'J', 'A', 'I', 'J', 'S'][d.weekday % 7];
                    });

                    final maxY = spots.isEmpty
                        ? 10.0
                        : (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.3)
                            .clamp(1.0, double.infinity);

                    return LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) =>
                              const FlLine(color: Colors.white10, strokeWidth: 1),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, _) => Text(
                                majina[val.toInt().clamp(0, 6)],
                                style: const TextStyle(color: Colors.white38, fontFamily: 'Poppins', fontSize: 11),
                              ),
                              reservedSize: 28,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 42,
                              getTitlesWidget: (val, _) => Text(
                                '${val.toInt()}K',
                                style: const TextStyle(color: Colors.white38, fontFamily: 'Poppins', fontSize: 10),
                              ),
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: 6,
                        minY: 0,
                        maxY: maxY,
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots.isEmpty
                                ? List.generate(7, (i) => FlSpot(i.toDouble(), 0))
                                : spots,
                            isCurved: true,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00C853), Color(0xFF00E5FF)],
                            ),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                                radius: spot.y > 0 ? 5 : 3,
                                color: const Color(0xFF00C853),
                                strokeColor: const Color(0xFF0F1629),
                                strokeWidth: 2,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFF00C853).withValues(alpha: 0.3),
                                  const Color(0xFF00C853).withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) => const Color(0xFF1A2035),
                            getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                              'TZS ${(s.y * 1000).toStringAsFixed(0)}',
                              const TextStyle(color: Color(0xFF00C853), fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                            )).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ).animate().scale(delay: 200.ms),

              const SizedBox(height: 28),

              // ── Bidhaa 5 Bora ─────────────────────────────────────
              const Text('🏆 Bidhaa 5 Zinazouzwa Zaidi',
                  style: TextStyle(
                      color: Colors.white, fontFamily: 'Poppins', fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              bidhaaAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00C853))),
                error: (_, __) => const SizedBox(),
                data: (bidhaaList) {
                  if (bidhaaList.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1629),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('Bado huna bidhaa zilizouzwa',
                            style: TextStyle(color: Colors.white54, fontFamily: 'Poppins')),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bidhaaList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final b = bidhaaList[i];
                      final colors = [
                        const Color(0xFFFFD700),
                        const Color(0xFFC0C0C0),
                        const Color(0xFFCD7F32),
                        const Color(0xFF00C853),
                        const Color(0xFF00E5FF),
                      ];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1629),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors[i].withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            // Namba ya nafasi
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: colors[i].withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text('#${i + 1}',
                                    style: TextStyle(
                                        color: colors[i],
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Picha
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A2035),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: b.pichaKuu.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(imageUrl: b.pichaKuu, fit: BoxFit.cover))
                                  : const Icon(Icons.inventory_2_outlined, color: Colors.white38, size: 20),
                            ),
                            const SizedBox(width: 12),
                            // Jina na bei
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(b.jina,
                                      style: const TextStyle(
                                          color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text(AppHelpers.formatBei(b.bei),
                                      style: const TextStyle(color: Colors.white54, fontFamily: 'Poppins', fontSize: 12)),
                                ],
                              ),
                            ),
                            // Mauzo
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${b.mauzo}',
                                    style: TextStyle(
                                        color: colors[i],
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                const Text('zimeuzwa',
                                    style: TextStyle(color: Colors.white38, fontFamily: 'Poppins', fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: (300 + i * 60).ms).slideX(begin: 0.1, end: 0);
                    },
                  );
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1629),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 14),
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(title,
                style: const TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'Poppins')),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 100, decoration: BoxDecoration(color: const Color(0xFF0F1629), borderRadius: BorderRadius.circular(18)))),
            const SizedBox(width: 12),
            Expanded(child: Container(height: 100, decoration: BoxDecoration(color: const Color(0xFF0F1629), borderRadius: BorderRadius.circular(18)))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: Container(height: 100, decoration: BoxDecoration(color: const Color(0xFF0F1629), borderRadius: BorderRadius.circular(18)))),
            const SizedBox(width: 12),
            Expanded(child: Container(height: 100, decoration: BoxDecoration(color: const Color(0xFF0F1629), borderRadius: BorderRadius.circular(18)))),
          ],
        ),
      ],
    ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(color: Colors.white10);
  }
}
