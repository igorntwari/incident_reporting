import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../application/auth_providers.dart';
import 'widgets/auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    // On success the router redirects automatically via the auth stream.
    await ref
        .read(authControllerProvider.notifier)
        .signIn(_email.text.trim(), _password.text);
  }

  Future<void> _forgotPassword() async {
    if (Validators.aluEmail(_email.text) != null) {
      context.showSnack('Enter your ALU email above first.', isError: true);
      return;
    }
    final sent = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_email.text.trim());
    if (sent && mounted) {
      context.showSnack('Password reset link sent to ${_email.text.trim()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listenForErrors(authControllerProvider, context);
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in with your ALU account to report and track campus issues.',
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EmailField(controller: _email, validator: Validators.aluEmail),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                controller: _password,
                validator: (v) => Validators.required(v, 'Password'),
                onSubmitted: _submit,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLoading ? null : _forgotPassword,
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                label: 'Sign in',
                isLoading: isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.md),
              AuthSwitchLink(
                prompt: "Don't have an account?",
                action: 'Sign up',
                onTap: () => context.go(AppRoutes.register),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
