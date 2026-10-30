import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Common layout for login, register and verification screens.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.icon = Icons.apartment_rounded,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: AppColors.heroGradient,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: Icon(icon, color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(AppConfig.appName,
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.primary),
                      textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.xs),
                  Text(title,
                      style: AppTextStyles.display, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.sm),
                  Text(subtitle,
                      style: AppTextStyles.bodySecondary,
                      textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.xl),
                  child,
                ],
              ),
            ),
          ),
        ),
      );
}

class EmailField extends StatelessWidget {
  const EmailField({super.key, required this.controller, this.validator});

  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          hintText: 'you@alustudent.com',
          prefixIcon: Icon(Icons.mail_outline_rounded),
        ),
      );
}

/// Password input with a show/hide toggle (purely local UI state).
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.validator,
    this.hint = 'Password',
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final String hint;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  var _obscured = true;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: widget.controller,
        validator: widget.validator,
        obscureText: _obscured,
        autofillHints: const [AutofillHints.password],
        textInputAction: widget.textInputAction,
        onFieldSubmitted: (_) => widget.onSubmitted?.call(),
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          suffixIcon: IconButton(
            tooltip: _obscured ? 'Show password' : 'Hide password',
            icon: Icon(_obscured
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
            onPressed: () => setState(() => _obscured = !_obscured),
          ),
        ),
      );
}

/// "Don't have an account? Sign up" style footer.
class AuthSwitchLink extends StatelessWidget {
  const AuthSwitchLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(prompt, style: AppTextStyles.bodySecondary),
          TextButton(onPressed: onTap, child: Text(action)),
        ],
      );
}
