import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.store_mall_directory_rounded,
      color: AppTheme.primary,
      kichwa: 'Fungua Duka Lako',
      maelezo:
          'Unda duka lako la mtandaoni kwa dakika chache. Ongeza bidhaa zako na uanze kuuza Tanzania nzima na duniani kote.',
    ),
    _OnboardingData(
      icon: Icons.shopping_bag_rounded,
      color: AppTheme.secondary,
      kichwa: 'Simamia Maagizo',
      maelezo:
          'Pokea na simamia maagizo ya wateja kwa urahisi. Fuatilia hali ya kila agizo kutoka kupokelewa hadi kufikishwa.',
    ),
    _OnboardingData(
      icon: Icons.bar_chart_rounded,
      color: AppTheme.accent,
      kichwa: 'Kukua kwa Haraka',
      maelezo:
          'Angalia takwimu za mauzo yako kwa wakati halisi. Jua bidhaa zinazouzwa zaidi na panga mkakati wa kukua biashara yako.',
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingDone, true);
    if (mounted) context.go('/ingia');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Ruka',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _OnboardingPage(data: _pages[index]);
                  },
                ),
              ),

              // Dots + Button
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingXL),
                child: Column(
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: 300.ms,
                          width: i == _currentPage ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: i == _currentPage
                                ? AppTheme.primary
                                : AppTheme.textHint,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage < _pages.length - 1) {
                            _controller.nextPage(
                              duration: 400.ms,
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _finish();
                          }
                        },
                        child: Text(
                          _currentPage < _pages.length - 1
                              ? 'Endelea'
                              : 'Anza Sasa!',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon circle with glow
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.color.withValues(alpha: 0.12),
              border: Border.all(color: data.color.withValues(alpha: 0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: data.color.withValues(alpha: 0.3),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(data.icon, color: data.color, size: 80),
          )
              .animate()
              .scale(duration: 500.ms, curve: Curves.elasticOut)
              .fadeIn(),

          const SizedBox(height: AppTheme.spacingXXL),

          Text(
            data.kichwa,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),

          const SizedBox(height: AppTheme.spacingM),

          Text(
            data.maelezo,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.2),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final Color color;
  final String kichwa;
  final String maelezo;

  _OnboardingData({
    required this.icon,
    required this.color,
    required this.kichwa,
    required this.maelezo,
  });
}
