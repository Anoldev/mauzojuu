import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class MipangilioScreen extends ConsumerWidget {
  const MipangilioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mtumiajiAsync = ref.watch(mtumiajiStreamProvider);
    final dukaAsync = ref.watch(dukaStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        title: const Text('Mipangilio',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
        backgroundColor: const Color(0xFF0F1629),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section — data halisi kutoka Firestore
          mtumiajiAsync.when(
            data: (mtumiaji) => GestureDetector(
              onTap: () => context.push('/profaili'),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F1629), Color(0xFF1A2540)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                      width: 1),
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00E5FF), Color(0xFF00C853)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          mtumiaji != null && mtumiaji.jina.isNotEmpty
                              ? mtumiaji.jina[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mtumiaji?.jina ?? '—',
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            mtumiaji?.barua ?? '—',
                            style: const TextStyle(
                                color: Colors.white54, fontFamily: 'Poppins'),
                          ),
                          dukaAsync.when(
                            data: (duka) => Text(
                              '🏪 ${duka?.jina ?? '—'}',
                              style: const TextStyle(
                                  color: Color(0xFF00C853),
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                            loading: () => const SizedBox(),
                            error: (_, __) => const SizedBox(),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_outlined,
                        color: Color(0xFF00E5FF), size: 20),
                  ],
                ),
              ),
            ),
            loading: () => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1629),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF1A2540),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            width: 120,
                            height: 16,
                            child: DecoratedBox(
                                decoration: BoxDecoration(
                                    color: Color(0xFF1A2540)))),
                        SizedBox(height: 8),
                        SizedBox(
                            width: 180,
                            height: 12,
                            child: DecoratedBox(
                                decoration: BoxDecoration(
                                    color: Color(0xFF1A2540)))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            error: (_, __) => const SizedBox(),
          ).animate().fadeIn().slideY(),

          const SizedBox(height: 32),
          const Text('Jumla',
              style: TextStyle(
                  color: Colors.white54,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          _buildSettingsTile(Icons.person_outline, 'Profaili Yangu', () => context.push('/profaili')),
          _buildSettingsTile(Icons.smart_toy_outlined, 'AI Msaidizi', () => context.push('/msaidizi'),
              rangi: const Color(0xFF00E5FF)),
          _buildSettingsTile(Icons.security, 'Usiri & Usalama', () {}),
          _buildSettingsTile(Icons.language, 'Lugha', () {},
              trailing: 'Kiswahili'),
          _buildSettingsTile(
              Icons.notifications_active, 'Taarifa (Notifications)', () {}),
          _buildSettingsTile(Icons.help_outline, 'Msaada', () {}),

          const SizedBox(height: 32),
          const Text('Akaunti',
              style: TextStyle(
                  color: Colors.white54,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // Logout — sahihi
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF0F1629),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: const Text('Toka kwenye akaunti?',
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Poppins')),
                    content: const Text('Je, unataka kutoka?',
                        style: TextStyle(
                            color: Colors.white54, fontFamily: 'Poppins')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Hapana',
                            style: TextStyle(
                                color: Colors.white54, fontFamily: 'Poppins')),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Ndio, Toka',
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await ref.read(authServiceProvider).toka();
                  if (context.mounted) context.go('/ingia');
                }
              },
              tileColor: const Color(0xFF0F1629),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Toka',
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white24),
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 48),
          const Center(
            child: Text('MauzoJuu v1.0.0',
                style: TextStyle(
                    color: Colors.white24,
                    fontFamily: 'Poppins',
                    fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? trailing,
    Color? rangi,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        tileColor: const Color(0xFF0F1629),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: rangi ?? const Color(0xFF00E5FF)),
        title: Text(title,
            style: const TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        trailing: trailing != null
            ? Text(trailing,
                style: const TextStyle(
                    color: Colors.white54, fontFamily: 'Poppins'))
            : const Icon(Icons.chevron_right, color: Colors.white54),
      ).animate().fadeIn().slideX(),
    );
  }
}
