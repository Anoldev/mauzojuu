import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _baruaCtrl = TextEditingController();
  final _nenoCtrl = TextEditingController();
  bool _inaonyeshaNeno = false;
  bool _inapakia = false;

  Future<void> _ingia() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _inapakia = true);

    final result = await ref.read(authServiceProvider).ingia(
      barua: _baruaCtrl.text.trim(),
      neno: _nenoCtrl.text,
    );

    if (!mounted) return;
    setState(() => _inapakia = false);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: AppTheme.danger,
        ),
      );
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTheme.spacingXXL),

                // Logo
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.trending_up_rounded,
                      color: Colors.black, size: 36),
                ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

                const SizedBox(height: AppTheme.spacingL),

                Text('Karibu Tena! 👋',
                        style: Theme.of(context).textTheme.displayMedium)
                    .animate(delay: 100.ms)
                    .fadeIn()
                    .slideX(begin: -0.1),

                const SizedBox(height: 8),

                Text(
                  'Ingia kwenye akaunti yako ya MauzoJuu',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ).animate(delay: 200.ms).fadeIn(),

                const SizedBox(height: AppTheme.spacingXXL),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email
                      TextFormField(
                        controller: _baruaCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Barua Pepe',
                          prefixIcon: Icon(Icons.email_outlined,
                              color: AppTheme.textHint),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Weka barua pepe';
                          if (!v.contains('@')) return 'Barua pepe si sahihi';
                          return null;
                        },
                      ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),

                      const SizedBox(height: AppTheme.spacingM),

                      // Password
                      TextFormField(
                        controller: _nenoCtrl,
                        obscureText: !_inaonyeshaNeno,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Neno la Siri',
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: AppTheme.textHint),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _inaonyeshaNeno
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppTheme.textHint,
                            ),
                            onPressed: () => setState(
                                () => _inaonyeshaNeno = !_inaonyeshaNeno),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Weka neno la siri';
                          if (v.length < 6) return 'Neno la siri ni fupi sana';
                          return null;
                        },
                      ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),

                      const SizedBox(height: AppTheme.spacingXL),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _inapakia ? null : _ingia,
                          child: _inapakia
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text('Ingia'),
                        ),
                      ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2),

                      const SizedBox(height: AppTheme.spacingL),

                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Huna akaunti? ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () => context.go('/jisajili'),
                            child: const Text(
                              'Jisajili Sasa',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ).animate(delay: 600.ms).fadeIn(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
