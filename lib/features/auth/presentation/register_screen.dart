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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    // Success signs the user in; the router then shows the verify screen.
    await ref.read(authControllerProvider.notifier).register(
          _name.text.trim(),
          _email.text.trim().toLowerCase(),
          _password.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listenForErrors(authControllerProvider, context);
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Only ALU email addresses can register. '
          'We will send you a verification link.',
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.md,
            children: [
              TextFormField(
                controller: _name,
                validator: Validators.fullName,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                decoration: const InputDecoration(
                  hintText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              EmailField(controller: _email, validator: Validators.aluEmail),
              PasswordField(
                controller: _password,
                validator: Validators.password,
                textInputAction: TextInputAction.next,
              ),
              PasswordField(
                controller: _confirm,
                hint: 'Confirm password',
                validator: Validators.confirmPassword(() => _password.text),
                onSubmitted: _submit,
              ),
              const SizedBox(height: AppSpacing.xs),
              PrimaryButton(
                label: 'Create account',
                isLoading: isLoading,
                onPressed: _submit,
              ),
              AuthSwitchLink(
                prompt: 'Already have an account?',
                action: 'Sign in',
                onTap: () => context.go(AppRoutes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
