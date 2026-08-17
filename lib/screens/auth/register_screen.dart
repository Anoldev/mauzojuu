import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jinaCtrl = TextEditingController();
  final _baruaCtrl = TextEditingController();
  final _simuCtrl = TextEditingController();
  final _dukaCtrl = TextEditingController();
  final _nenoCtrl = TextEditingController();
  bool _inaonyeshaNeno = false;
  bool _inapakia = false;

  Future<void> _jisajili() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _inapakia = true);

    final result = await ref.read(authServiceProvider).jisajili(
      jina: _jinaCtrl.text.trim(),
      barua: _baruaCtrl.text.trim(),
      simu: _simuCtrl.text.trim(),
      jinalaDuka: _dukaCtrl.text.trim(),
      neno: _nenoCtrl.text,
    );

    if (!mounted) return;
    setState(() => _inapakia = false);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result), backgroundColor: AppTheme.danger),
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
                const SizedBox(height: AppTheme.spacingL),
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: AppTheme.textPrimary),
                  onPressed: () => context.go('/ingia'),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text('Fungua Duka Lako! 🚀',
                    style: Theme.of(context).textTheme.displayMedium)
                    .animate().fadeIn().slideX(begin: -0.1),
                const SizedBox(height: 8),
                Text(
                  'Jisajili na uanze kuuza leo hii',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ).animate(delay: 100.ms).fadeIn(),
                const SizedBox(height: AppTheme.spacingXL),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildField(
                        controller: _jinaCtrl,
                        label: 'Jina Lako Kamili',
                        icon: Icons.person_outline,
                        delay: 150,
                        validator: (v) => v!.isEmpty ? 'Weka jina lako' : null,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      _buildField(
                        controller: _dukaCtrl,
                        label: 'Jina la Duka Lako',
                        icon: Icons.store_outlined,
                        delay: 200,
                        validator: (v) =>
                            v!.isEmpty ? 'Weka jina la duka' : null,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      _buildField(
                        controller: _simuCtrl,
                        label: 'Nambari ya Simu (Tanzania)',
                        icon: Icons.phone_outlined,
                        type: TextInputType.phone,
                        delay: 250,
                        validator: (v) {
                          if (v!.isEmpty) return 'Weka nambari ya simu';
                          if (v.length < 10) return 'Nambari si sahihi';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      _buildField(
                        controller: _baruaCtrl,
                        label: 'Barua Pepe',
                        icon: Icons.email_outlined,
                        type: TextInputType.emailAddress,
                        delay: 300,
                        validator: (v) {
                          if (v!.isEmpty) return 'Weka barua pepe';
                          if (!v.contains('@')) return 'Barua pepe si sahihi';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingM),
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
                          if (v!.isEmpty) return 'Weka neno la siri';
                          if (v.length < 6) return 'Neno la siri ni fupi sana (angalau herufi 6)';
                          return null;
                        },
                      ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: AppTheme.spacingXL),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _inapakia ? null : _jisajili,
                          child: _inapakia
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text('Fungua Duka Sasa!'),
                        ),
                      ).animate(delay: 400.ms).fadeIn(),
                      const SizedBox(height: AppTheme.spacingL),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Una akaunti tayari? ',
                              style: Theme.of(context).textTheme.bodyMedium),
                          TextButton(
                            onPressed: () => context.go('/ingia'),
                            child: const Text('Ingia',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                )),
                          ),
                        ],
                      ).animate(delay: 450.ms).fadeIn(),
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int delay = 0,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textHint),
      ),
      validator: validator,
    ).animate(delay: Duration(milliseconds: delay)).fadeIn().slideY(begin: 0.2);
  }
}
