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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).signUpWithEmail(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            fullName: _nameCtrl.text.trim(),
          );
      if (mounted) context.go(Routes.explore);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go(Routes.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacings.base),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacings.lg),
                const Text(
                  'Criar conta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: AppSpacings.sm),
                const Text(
                  'Junte-se a milhares de viajantes em Ubatuba',
                  style: TextStyle(color: AppColors.warmGray),
                ),
                const SizedBox(height: AppSpacings.xl),
                AuthTextField(
                  controller: _nameCtrl,
                  label: 'Nome completo',
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.required(v, 'Nome'),
                ),
                const SizedBox(height: AppSpacings.base),
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
                  textInputAction: TextInputAction.next,
                  validator: Validators.password,
                ),
                const SizedBox(height: AppSpacings.base),
                AuthTextField(
                  controller: _confirmCtrl,
                  label: 'Confirmar senha',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: _signUp,
                  validator: (v) => Validators.confirmPassword(v, _passwordCtrl.text),
                ),
                const SizedBox(height: AppSpacings.lg),
                AppButton(
                  label: 'Criar conta',
                  onPressed: _loading ? null : _signUp,
                  loading: _loading,
                ),
                const SizedBox(height: AppSpacings.base),
                const Text(
                  'Ao criar sua conta, você concorda com nossos Termos de Uso e Política de Privacidade.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.warmGray),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
