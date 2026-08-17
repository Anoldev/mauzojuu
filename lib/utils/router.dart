import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/bidhaa/bidhaa_screen.dart';
import '../screens/bidhaa/ongeza_bidhaa_screen.dart';
import '../screens/bidhaa/bidhaa_detail_screen.dart';
import '../screens/maagizo/maagizo_screen.dart';
import '../screens/maagizo/agizo_detail_screen.dart';
import '../screens/duka/duka_screen.dart';
import '../screens/ripoti/ripoti_screen.dart';
import '../screens/mipangilio/mipangilio_screen.dart';
import '../screens/profaili/profaili_screen.dart';
import '../screens/msaidizi/msaidizi_screen.dart';
import 'main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final loggingIn = state.matchedLocation == '/ingia' ||
          state.matchedLocation == '/jisajili';
      final onSplash = state.matchedLocation == '/splash';
      final onOnboarding = state.matchedLocation == '/onboarding';

      if (onSplash || onOnboarding) return null;
      if (user == null && !loggingIn) return '/ingia';
      if (user != null && loggingIn) return '/';

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/ingia', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/jisajili', builder: (c, s) => const RegisterScreen()),
      // AI Msaidizi — nje ya shell (full screen experience)
      GoRoute(
          path: '/msaidizi', builder: (c, s) => const MsaidiaziScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (c, s) => const DashboardScreen()),
          GoRoute(
            path: '/bidhaa',
            builder: (c, s) => const BidhaaScreen(),
            routes: [
              GoRoute(
                path: 'mpya',
                builder: (c, s) => const OngezaBidhaaScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (c, s) =>
                    BidhaaDetailScreen(bidhaaId: s.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/maagizo',
            builder: (c, s) => const MaagizoScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (c, s) =>
                    AgizoDetailScreen(agizoId: s.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(path: '/duka', builder: (c, s) => const DukaScreen()),
          GoRoute(path: '/ripoti', builder: (c, s) => const RipotiScreen()),
          GoRoute(
              path: '/mipangilio',
              builder: (c, s) => const MipangilioScreen()),
          GoRoute(
              path: '/profaili', builder: (c, s) => const ProfailiScreen()),
        ],
      ),
    ],
  );
});
