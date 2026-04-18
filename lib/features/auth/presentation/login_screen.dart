import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacings.dart';
import '../../../core/utils/validators.dart';
import '../../../router/routes.dart';
import '../../../shared/widgets/app_button.dart';
import 'auth_provider.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/google_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithEmail(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
          );
      if (mounted) context.go(Routes.explore);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao entrar: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro Google: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacings.base),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacings.xxl),
                // Logo
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.coral,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.coral.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.waves_rounded, color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: AppSpacings.base),
                      const Text(
                        'Ubatuba',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const Text(
                        'Sua hospedagem ideal na costa',
                        style: TextStyle(fontSize: 14, color: AppColors.warmGray),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacings.xxl),
                AuthTextField(
                  controller: _emailCtrl,
                  label: 'E-mail',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacings.base),
                AuthTextField(
                  controller: _passwordCtrl,
                  label: 'Senha',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: _signIn,
                  validator: Validators.password,
                ),
                const SizedBox(height: AppSpacings.lg),
                AppButton(
                  label: 'Entrar',
                  onPressed: _loading ? null : _signIn,
                  loading: _loading,
                ),
                const SizedBox(height: AppSpacings.base),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('ou', style: TextStyle(color: AppColors.warmGray, fontSize: 13)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: AppSpacings.base),
                GoogleSignInButton(onPressed: _signInWithGoogle),
                const SizedBox(height: AppSpacings.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Não tem conta? ', style: TextStyle(color: AppColors.warmGray)),
                    GestureDetector(
                      onTap: () => context.go(Routes.register),
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(
                          color: AppColors.coral,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
