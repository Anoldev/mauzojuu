import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/bidhaa_service.dart';
import '../../services/agizo_service.dart';
import '../../utils/helpers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mtumiaji = ref.watch(authServiceProvider).mtumiaji;
    final bidhaaAsync = ref.watch(bidhaaCountProvider);
    final maagizoAsync = ref.watch(maagizoStatsProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      floatingActionButton: _AiFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Habari yako! 👋',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                            Text(
                              mtumiaji?.displayName ?? 'Mfanyabiashara',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium,
                            ),
                          ],
                        ),
                      ),
                      // Notification bell
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          border: Border.all(
                              color: const Color(0xFF1E2D50), width: 1),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            color: AppTheme.textSecondary),
                      ),
                    ],
                  ).animate().fadeIn().slideY(begin: -0.1),
                ),
              ),

              // Stats Cards
              SliverToBoxAdapter(
                child: maagizoAsync.when(
                  data: (stats) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingL),
                    child: Column(
                      children: [
                        // Main revenue card
                        _MauzoKuuCard(
                          mauzoLeo: stats['mauzoLeo'] ?? 0,
                          mauzoMwezi: stats['mauzoMwezi'] ?? 0,
                        ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: AppTheme.spacingM),
                        // Small stats row
                        Row(
                          children: [
                            Expanded(
                              child: _StatsCard(
                                kichwa: 'Maagizo',
                                thamani:
                                    '${stats['maagizaYote'] ?? 0}',
                                icon: Icons.shopping_bag_rounded,
                                rangi: AppTheme.secondary,
                                subtitle: 'Yote',
                              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
                            ),
                            const SizedBox(width: AppTheme.spacingM),
                            Expanded(
                              child: _StatsCard(
                                kichwa: 'Yanasubiri',
                                thamani:
                                    '${stats['yanayosubiri'] ?? 0}',
                                icon: Icons.pending_rounded,
                                rangi: const Color(0xFFFF9800),
                                subtitle: 'Maagizo',
                              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Row(
                          children: [
                            Expanded(
                              child: bidhaaAsync.when(
                                data: (count) => _StatsCard(
                                  kichwa: 'Bidhaa',
                                  thamani: '$count',
                                  icon: Icons.inventory_2_rounded,
                                  rangi: AppTheme.accent,
                                  subtitle: 'Zilizoorodheshwa',
                                ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.2),
                                loading: () => const _StatsCardSkeleton(),
                                error: (_, __) => const SizedBox(),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingM),
                            Expanded(
                              child: _StatsCard(
                                kichwa: 'Zimefika',
                                thamani: '${stats['zimefika'] ?? 0}',
                                icon: Icons.check_circle_rounded,
                                rangi: AppTheme.primary,
                                subtitle: 'Maagizo',
                              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppTheme.spacingL),
                    child: _StatsSkeleton(),
                  ),
                  error: (e, _) => const SizedBox(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingL)),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vitendo vya Haraka',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppTheme.spacingM),
                      Row(
                        children: [
                          _QuickAction(
                            icon: Icons.add_box_rounded,
                            label: 'Ongeza\nBidhaa',
                            rangi: AppTheme.primary,
                            onTap: () => context.go('/bidhaa/mpya'),
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          _QuickAction(
                            icon: Icons.shopping_bag_rounded,
                            label: 'Ona\nMaagizo',
                            rangi: AppTheme.secondary,
                            onTap: () => context.go('/maagizo'),
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          _QuickAction(
                            icon: Icons.store_rounded,
                            label: 'Duka\nLangu',
                            rangi: AppTheme.accent,
                            onTap: () => context.go('/duka'),
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          _QuickAction(
                            icon: Icons.bar_chart_rounded,
                            label: 'Ripoti\nZangu',
                            rangi: const Color(0xFFE040FB),
                            onTap: () => context.go('/ripoti'),
                          ),
                        ],
                      ),
                    ],
                  ).animate(delay: 450.ms).fadeIn(),
                ),
              ),

              // AI Sales Assistant Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                  child: GestureDetector(
                    onTap: () => context.push('/msaidizi'),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D1F3C), Color(0xFF1A1040)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('M',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ).animate(onPlay: (c) => c.repeat()).shimmer(
                              duration: 3.seconds,
                              color: Colors.white24),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('🤖 Mauzo — AI Sales Assistant',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                  'Msaidizi wako hodari — anajua bidhaa, mauzo, na maagizo yako. Uliza chochote!',
                                  style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontFamily: 'Poppins',
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: Color(0xFF00E5FF), size: 24),
                        ],
                      ),
                    ),
                  ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingXXL)),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets ndogo ──────────────────────────────────────────────────

class _AiFab extends StatefulWidget {
  @override
  State<_AiFab> createState() => _AiFabState();
}

class _AiFabState extends State<_AiFab> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) => GestureDetector(
        onTap: () => context.push('/msaidizi'),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: _glow.value),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Text('🤖',
                style: TextStyle(fontSize: 26)),
          ),
        ),
      ),
    );
  }
}


class _MauzoKuuCard extends StatelessWidget {
  final double mauzoLeo;
  final double mauzoMwezi;

  const _MauzoKuuCard({required this.mauzoLeo, required this.mauzoMwezi});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up_rounded,
                  color: Colors.black, size: 20),
              const SizedBox(width: 8),
              Text(
                'Mauzo ya Leo',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppHelpers.formatBei(mauzoLeo),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Mwezi huu: ${AppHelpers.formatBei(mauzoMwezi)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String kichwa;
  final String thamani;
  final IconData icon;
  final Color rangi;
  final String subtitle;

  const _StatsCard({
    required this.kichwa,
    required this.thamani,
    required this.icon,
    required this.rangi,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: const Color(0xFF1E2D50), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rangi.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: rangi, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            thamani,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$kichwa\n$subtitle',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppTheme.textHint),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color rangi;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.rangi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
          decoration: BoxDecoration(
            color: rangi.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: rangi.withValues(alpha: 0.2), width: 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: rangi, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsCardSkeleton extends StatelessWidget {
  const _StatsCardSkeleton();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
